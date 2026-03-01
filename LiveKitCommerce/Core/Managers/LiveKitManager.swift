//
//  LiveKitManager.swift
//  LiveKitCommerce
//
//  Created by Nishant Gulani on 01/03/26.
//

import Foundation
import LiveKit
import AVFoundation

final class LiveKitManager: NSObject {

    static let shared = LiveKitManager()

    private(set) var room: Room?
    var localAudioTrack: LocalAudioTrack?

    // MARK: - Credentials

    private let liveKitURL = "wss://virtualshoppingapp-oxlt3ddi.livekit.cloud"
    /// Replace with a valid token or wire up a token-generation service.
    private let token = "GENERATE_TOKEN_HERE"

    // MARK: - Audio Level Monitoring

    /// Called on the main thread with a normalised level (0.0 – 1.0).
    var onAudioLevel: ((Float) -> Void)?

    /// Dedicated AVAudioEngine that taps the mic hardware directly.
    /// This is independent of WebRTC's internal audio pipeline, which does NOT
    /// forward raw PCM to external renderers reliably on iOS.
    private var levelEngine: AVAudioEngine?
    private var lastLevelEmitDate: Date = .distantPast

    // MARK: - Init

    private override init() {}

    // MARK: - Public API

    func connect(identity: String,
                 completion: @escaping (Result<Void, Error>) -> Void) {

        let newRoom = Room()
        room = newRoom

        Task {
            do {
                try await newRoom.connect(url: liveKitURL, token: token)
                try await publishAudio()

                await MainActor.run {
                    completion(.success(()))
                }

            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }

    func setMicMuted(_ muted: Bool) async {
        if muted {
            try? await localAudioTrack?.mute()
        } else {
            try? await localAudioTrack?.unmute()
        }
    }

    func disconnect() async {
        stopMicLevelMonitoring()
        if let room {
            await room.disconnect()
        }
        room = nil
        localAudioTrack = nil
    }

    // MARK: - Private

    private func publishAudio() async throws {
        guard let room else {
            throw NSError(
                domain: "LiveKit",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Room not initialised"]
            )
        }

        try AVAudioSession.sharedInstance().setCategory(
            .playAndRecord,
            mode: .voiceChat,
            options: [.defaultToSpeaker, .allowBluetooth]
        )
        try AVAudioSession.sharedInstance().setActive(true)

        // createTrack() triggers the system microphone permission prompt if not yet decided.
        let track = try await LocalAudioTrack.createTrack()
        localAudioTrack = track

        try await room.localParticipant.publish(audioTrack: track)

        // Start mic tap AFTER the audio session is active and track is published.
        await MainActor.run { self.startMicLevelMonitoring() }
    }

    // MARK: - Mic Level Monitoring via AVAudioEngine

    /// Taps the live microphone hardware input directly.
    /// AVAudioEngine and WebRTC share the same AVAudioSession, so both can
    /// read from the mic simultaneously once the session is .playAndRecord active.
    private func startMicLevelMonitoring() {
        stopMicLevelMonitoring()

        let engine = AVAudioEngine()
        levelEngine = engine
        let inputNode = engine.inputNode

        // Use the hardware format to avoid any sample-rate mismatch errors.
        let format = inputNode.inputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 512, format: format) { [weak self] buffer, _ in
            guard let self else { return }

            // Throttle to ~20 fps
            let now = Date()
            guard now.timeIntervalSince(self.lastLevelEmitDate) >= 0.05 else { return }
            self.lastLevelEmitDate = now

            guard let channelData = buffer.floatChannelData?[0] else { return }
            let frameLength = Int(buffer.frameLength)
            guard frameLength > 0 else { return }

            // Root-mean-square of first channel
            var sumSquares: Float = 0
            for i in 0..<frameLength {
                let s = channelData[i]
                sumSquares += s * s
            }
            let rms = sqrtf(sumSquares / Float(frameLength))

            // Scale: typical speech RMS is 0.005–0.05; ×25 maps that to 0.1–1.0
            let level = min(1.0, rms * 25.0)

            DispatchQueue.main.async { self.onAudioLevel?(level) }
        }

        do {
            try engine.start()
        } catch {
            // Engine failed to start (e.g., simulator or session conflict).
            // Visualizer will stay at idle — connection still works normally.
            levelEngine = nil
        }
    }

    private func stopMicLevelMonitoring() {
        levelEngine?.inputNode.removeTap(onBus: 0)
        levelEngine?.stop()
        levelEngine = nil
    }
}

//
//  LiveKitManager.swift
//  LiveKitCommerce
//
//  Created by Nishant Gulani on 01/03/26.
//

import Foundation
import LiveKit
import AVFoundation

final class LiveKitManager {

    static let shared = LiveKitManager()

    private var room: Room?
    private var localAudioTrack: LocalAudioTrack?

    private let liveKitURL = "wss://virtualshoppingapp-oxlt3ddi.livekit.cloud"
    private let token = "GENERATE_TOKEN_HERE"

    private init() {}

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

    func disconnect() async {
        if let room = room {
            await room.disconnect()
        }
        room = nil
        localAudioTrack = nil
    }

    private func publishAudio() async throws {

        guard let room = room else {
            throw NSError(domain: "LiveKit",
                          code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Room not initialized"])
        }

        try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
        try AVAudioSession.sharedInstance().setActive(true)

        localAudioTrack = try await LocalAudioTrack.createTrack()

        if let audioTrack = localAudioTrack {
            try await room.localParticipant.publish(audioTrack: audioTrack)
        }
    }
}

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

    func connect(completion: @escaping (Result<Void, Error>) -> Void) {
        room = Room()

        Task {
            do {
                try await room?.connect(url: liveKitURL, token: token)
                print("✅ Room connected successfully")

                publishAudio()

                completion(.success(()))
            } catch {
                print("❌ Room connection failed:", error)
                completion(.failure(error))
            }
        }
    }

    private func publishAudio() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if !granted {
                print("❌ Microphone permission denied")
                return
            }

            Task {
                do {
                    try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
                    try AVAudioSession.sharedInstance().setActive(true)

                    self.localAudioTrack = try await LocalAudioTrack.createTrack()

                    if let audioTrack = self.localAudioTrack {
                        try await self.room?.localParticipant.publish(audioTrack: audioTrack)
                    }

                    print("🎤 Audio published successfully")

                } catch {
                    print("❌ Audio publish error:", error)
                }
            }
        }
    }
}

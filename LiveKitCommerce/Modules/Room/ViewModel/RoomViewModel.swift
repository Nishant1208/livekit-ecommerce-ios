//
//  RoomViewModel.swift
//  LiveKitCommerce
//
//  Created by Nishant Gulani on 01/03/26.
//

import Foundation
import LiveKit
import AVFoundation

// MARK: - Connection State (UI representation)

enum RoomConnectionState {
    case connected
    case reconnecting
    case disconnected

    var displayText: String {
        switch self {
        case .connected:    return "Connected"
        case .reconnecting: return "Reconnecting..."
        case .disconnected: return "Disconnected"
        }
    }
}

// MARK: - ViewModel

final class RoomViewModel: NSObject {

    // MARK: - Callbacks (UI observes these)
    var onConnectionStateChange: ((RoomConnectionState) -> Void)?
    var onVideoStateChange: ((Bool) -> Void)?           // isVideoEnabled
    var onMicStateChange: ((Bool) -> Void)?             // isMuted
    var onVideoTrackReady: ((LocalVideoTrack?) -> Void)?
    var onLeaveRoom: (() -> Void)?

    // MARK: - State
    private(set) var connectionState: RoomConnectionState = .connected
    private(set) var isVideoEnabled = false
    private(set) var isMicMuted     = false
    private(set) var cameraPosition: AVCaptureDevice.Position = .front

    private var localVideoTrack: LocalVideoTrack?

    private var room: Room? { LiveKitManager.shared.room }

    // MARK: - Init

    override init() {
        super.init()
        room?.delegates.add(delegate: self)
    }

    // MARK: - Mic

    func toggleMic() {
        isMicMuted = !isMicMuted
        let muted = isMicMuted
        Task { await LiveKitManager.shared.setMicMuted(muted) }
        onMicStateChange?(isMicMuted)
    }

    // MARK: - Video

    func toggleVideo() {
        if isVideoEnabled {
            disableVideo()
        } else {
            enableVideo()
        }
    }

    private func enableVideo() {
        guard let room else { return }

        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard let self, granted else { return }
            Task {
                do {
                    let options = CameraCaptureOptions(position: self.cameraPosition)
                    let track = LocalVideoTrack.createCameraTrack(options: options)  // sync, no await
                    try await room.localParticipant.publish(videoTrack: track)
                    self.localVideoTrack = track
                    self.isVideoEnabled  = true
                    await MainActor.run {
                        self.onVideoStateChange?(true)
                        self.onVideoTrackReady?(track)
                    }
                } catch {
                    print("[RoomVM] Enable video error: \(error)")
                }
            }
        }
    }

    private func disableVideo() {
        guard let room else { return }
        Task {
            if let pub = room.localParticipant.localVideoTracks.first {
                try? await room.localParticipant.unpublish(publication: pub)
            }
            localVideoTrack = nil
            isVideoEnabled  = false
            await MainActor.run {
                self.onVideoStateChange?(false)
                self.onVideoTrackReady?(nil)
            }
        }
    }

    // MARK: - Camera Flip

    func flipCamera() {
        guard isVideoEnabled, let room else { return }
        cameraPosition = cameraPosition == .front ? .back : .front
        Task {
            do {
                if let pub = room.localParticipant.localVideoTracks.first {
                    try await room.localParticipant.unpublish(publication: pub)
                }
                let options = CameraCaptureOptions(position: cameraPosition)
                let track = LocalVideoTrack.createCameraTrack(options: options)  // sync
                try await room.localParticipant.publish(videoTrack: track)
                localVideoTrack = track
                await MainActor.run { self.onVideoTrackReady?(track) }
            } catch {
                print("[RoomVM] Flip camera error: \(error)")
            }
        }
    }

    // MARK: - Leave

    func leaveRoom() {
        Task {
            await LiveKitManager.shared.disconnect()
            await MainActor.run { self.onLeaveRoom?() }
        }
    }
}

// MARK: - RoomDelegate

extension RoomViewModel: RoomDelegate {

    func room(_ room: Room, didUpdateConnectionState connectionState: ConnectionState,
              from oldConnectionState: ConnectionState) {
        let mapped: RoomConnectionState
        switch connectionState {
        case .connected:    mapped = .connected
        case .reconnecting: mapped = .reconnecting
        default:            mapped = .disconnected
        }
        DispatchQueue.main.async { [weak self] in
            self?.connectionState = mapped
            self?.onConnectionStateChange?(mapped)
        }
    }
}

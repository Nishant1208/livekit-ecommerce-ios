//
//  LandingViewModel.swift
//  LiveKitCommerce
//
//  Created by Nishant Gulani on 01/03/26.
//

import Foundation
import AVFoundation

// MARK: - State

enum LandingState {
    case idle
    case connecting
    case connected
    /// - isPermissionError: true when the error is a microphone permission denial.
    case error(message: String, isPermissionError: Bool)
}

// MARK: - ViewModel

final class LandingViewModel {

    var onStateChange: ((LandingState) -> Void)?

    private(set) var state: LandingState = .idle {
        didSet { onStateChange?(state) }
    }

    // MARK: - Actions

    func startSession(identity: String) {
        let trimmed = identity.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            state = .error(message: "Please enter your name to continue.", isPermissionError: false)
            return
        }

        state = .connecting

        LiveKitManager.shared.connect(identity: trimmed) { [weak self] result in
            switch result {
            case .success:
                self?.state = .connected

            case .failure(let error):
                let isPermission = AVAudioSession.sharedInstance().recordPermission == .denied
                let message = isPermission
                    ? "Microphone access is required. Please enable it in Settings."
                    : error.localizedDescription
                self?.state = .error(message: message, isPermissionError: isPermission)
            }
        }
    }

    func retry(identity: String) {
        startSession(identity: identity)
    }

    func permissionDenied() {
        state = .error(
            message: "Microphone access is required. Please enable it in Settings.",
            isPermissionError: true
        )
    }

    func disconnect() {
        Task {
            await LiveKitManager.shared.disconnect()
            await MainActor.run {
                self.state = .idle
            }
        }
    }
}

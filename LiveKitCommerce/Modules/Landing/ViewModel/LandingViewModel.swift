//
//  LandingViewModel.swift
//  LiveKitCommerce
//
//  Created by Nishant Gulani on 01/03/26.
//
import Foundation

enum LandingState {
    case idle
    case connecting
    case connected
    case error(message: String)
}

final class LandingViewModel {

    var onStateChange: ((LandingState) -> Void)?

    private(set) var state: LandingState = .idle {
        didSet { onStateChange?(state) }
    }

    func startSession(identity: String) {

        let trimmed = identity.trimmingCharacters(in: .whitespaces)

        guard !trimmed.isEmpty else {
            state = .error(message: "Please enter your name.")
            return
        }

        state = .connecting

        LiveKitManager.shared.connect(identity: trimmed) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.state = .connected

                case .failure(let error):
                    self?.state = .error(message: error.localizedDescription)
                }
            }
        }
    }

    func retry(identity: String) {
        startSession(identity: identity)
    }

    func permissionDenied() {
        state = .error(message: "Microphone permission is required. Please enable it in Settings.")
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

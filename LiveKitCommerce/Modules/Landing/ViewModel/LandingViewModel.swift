//
//  LandingViewModel.swift
//  LiveKitCommerce
//
//  Created by Nishant Gulani on 01/03/26.
//
import Foundation

final class LandingViewModel {

    var onLoadingChanged: ((Bool) -> Void)?
    var onConnectionSuccess: (() -> Void)?
    var onError: ((String) -> Void)?

    func startSession() {
        onLoadingChanged?(true)

        LiveKitManager.shared.connect { [weak self] result in
            DispatchQueue.main.async {
                self?.onLoadingChanged?(false)

                switch result {
                case .success:
                    self?.onConnectionSuccess?()
                case .failure(let error):
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
}

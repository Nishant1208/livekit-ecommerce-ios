//
//  LandingViewController.swift
//  LiveKitCommerce
//
//  Created by Nishant Gulani on 01/03/26.
//

import UIKit
import Lottie
import AVFoundation

final class LandingViewController: UIViewController {

    // MARK: - State Views
    @IBOutlet private weak var contentContainer: UIView!
    @IBOutlet private weak var idleView: UIView!
    @IBOutlet private weak var connectingView: UIView!
    @IBOutlet private weak var connectedView: UIView!
    @IBOutlet private weak var errorView: UIView!

    // MARK: - Input
    @IBOutlet private weak var nameTextField: UITextField!

    // MARK: - Button Containers (IMPORTANT)
    @IBOutlet private weak var startButtonContainer: UIView!
    @IBOutlet private weak var continueButtonContainer: UIView!
    @IBOutlet private weak var tryAgainButtonContainer: UIView!

    // MARK: - Buttons
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var continueButton: UIButton!
    @IBOutlet private weak var tryAgainButton: UIButton!
    @IBOutlet private weak var disconnectButton: UIButton!

    // MARK: - Labels
    @IBOutlet private weak var errorMessageLabel: UILabel!

    // MARK: - Lottie Containers
    @IBOutlet private weak var connectingAnimationContainer: UIView!
    @IBOutlet private weak var successAnimationContainer: UIView!

    private let viewModel = LandingViewModel()
    private var connectingAnimation: LottieAnimationView?
    private var successAnimation: LottieAnimationView?
    private var audioTimer: Timer?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bindViewModel()
        setupAnimations()
        render(state: .idle)
    }

    deinit {
        stopAnimations()
        stopAudioVisualizer()
    }

    // MARK: - UI Setup

    private func configureUI() {
        startButtonContainer.layer.cornerRadius = 16
        continueButtonContainer.layer.cornerRadius = 16
        tryAgainButtonContainer.layer.cornerRadius = 16

        continueButtonContainer.alpha = 0
    }

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.render(state: state)
        }
    }

    // MARK: - State Rendering

    private func render(state: LandingState) {
        UIView.transition(
            with: contentContainer,
            duration: 0.35,
            options: .transitionCrossDissolve,
            animations: {
                self.apply(state: state)
            }
        )
    }

    private func apply(state: LandingState) {

        idleView.isHidden = true
        connectingView.isHidden = true
        connectedView.isHidden = true
        errorView.isHidden = true

        stopAnimations()
        stopAudioVisualizer()

        switch state {

        case .idle:
            idleView.isHidden = false
            animateStartContainer(enabled: true)

        case .connecting:
            connectingView.isHidden = false
            animateStartContainer(enabled: false)
            connectingAnimation?.play()

        case .connected:
            connectedView.isHidden = false
            successAnimation?.loopMode = .playOnce
            successAnimation?.play()
            fadeInContinueContainer()
            startAudioVisualizer()

        case .error(let message):
            errorView.isHidden = false
            errorMessageLabel.text = message
            animateStartContainer(enabled: true)
        }
    }

    // MARK: - Button Container Animations

    private func animateStartContainer(enabled: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.startButtonContainer.alpha = enabled ? 1.0 : 0.5
            self.startButton.isEnabled = enabled
        }
    }

    private func fadeInContinueContainer() {
        continueButtonContainer.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.continueButtonContainer.alpha = 1
        }
    }

    // MARK: - Lottie Setup

    private func setupAnimations() {

        connectingAnimation = createLottie(named: "loading_spinner")
        successAnimation = createLottie(named: "success_check")

        if let connectingAnimation {
            embed(animation: connectingAnimation, in: connectingAnimationContainer)
        }

        if let successAnimation {
            embed(animation: successAnimation, in: successAnimationContainer)
        }
    }

    private func createLottie(named name: String) -> LottieAnimationView {
        let animation = LottieAnimationView(name: name)
        animation.loopMode = .loop
        animation.contentMode = .scaleAspectFit
        return animation
    }

    private func embed(animation: LottieAnimationView, in container: UIView) {
        animation.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(animation)

        NSLayoutConstraint.activate([
            animation.topAnchor.constraint(equalTo: container.topAnchor),
            animation.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            animation.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animation.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
    }

    private func stopAnimations() {
        connectingAnimation?.stop()
        successAnimation?.stop()
    }

    // MARK: - Audio Visualizer (Dummy Hook)

    private func startAudioVisualizer() {
        stopAudioVisualizer()
        audioTimer = Timer.scheduledTimer(
            withTimeInterval: 0.2,
            repeats: true
        ) { _ in
            print("Simulated audio level update")
        }
    }

    private func stopAudioVisualizer() {
        audioTimer?.invalidate()
        audioTimer = nil
    }

    // MARK: - Permission + Start Flow

    private func requestPermissionAndStart() {

        guard let name = nameTextField.text,
              !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            viewModel.permissionDenied()
            return
        }

        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    self.viewModel.startSession(identity: name)
                } else {
                    self.viewModel.permissionDenied()
                }
            }
        }
    }

    // MARK: - Actions

    @IBAction private func startTapped(_ sender: UIButton) {
        requestPermissionAndStart()
    }

    @IBAction private func tryAgainTapped(_ sender: UIButton) {
        viewModel.retry(identity: nameTextField.text ?? "")
    }

    @IBAction private func continueTapped(_ sender: UIButton) {
        print("Navigate to Room Screen")
    }

    @IBAction private func disconnectTapped(_ sender: UIButton) {
        viewModel.disconnect()
    }

    @IBAction private func openSettingsTapped(_ sender: UIButton) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

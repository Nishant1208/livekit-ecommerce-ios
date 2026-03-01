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

    // MARK: - State Container Views

    @IBOutlet private weak var contentContainer: UIView!
    @IBOutlet private weak var idleView: UIView!
    @IBOutlet private weak var connectingView: UIView!
    @IBOutlet private weak var connectedView: UIView!
    @IBOutlet private weak var errorView: UIView!

    // MARK: - Input

    @IBOutlet private weak var nameTextField: UITextField!

    // MARK: - Button Containers

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
    @IBOutlet private weak var errorTitleLabel: UILabel!         // "Connection Failed" title

    // MARK: - Image Views

    @IBOutlet private weak var errorIconImageView: UIImageView!  // Error state icon

    // MARK: - Lottie Containers

    @IBOutlet private weak var connectingAnimationContainer: UIView!
    @IBOutlet private weak var successAnimationContainer: UIView!

    // MARK: - Audio Level Container (placeholder view from XIB)

    @IBOutlet private weak var audioLevelContainer: UIView!

    // MARK: - Lottie Views

    private var connectingAnimation: LottieAnimationView?
    private var successAnimation: LottieAnimationView?
    private var audioWaveAnimation: LottieAnimationView?

    // MARK: - Programmatic Subviews

    private var connectedBadgeView: UIView?
    private var openSettingsButton: UIButton?

    // MARK: - ViewModel

    private let viewModel = LandingViewModel()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupAnimations()
        setupConnectedBadge()
        setupOpenSettingsButton()
        bindViewModel()
        render(state: .idle)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        // Reset to idle when returning from the room screen
        if case .connected = viewModel.state {
            viewModel.disconnect()
        }
        view.alpha = 1  // restore if we left with a fade animation
    }

    deinit {
        connectingAnimation?.stop()
        successAnimation?.stop()
        audioWaveAnimation?.stop()
        LiveKitManager.shared.onAudioLevel = nil
    }

    // MARK: - UI Configuration

    private func configureUI() {
        startButtonContainer.layer.cornerRadius = 16
        continueButtonContainer.layer.cornerRadius = 16
        tryAgainButtonContainer.layer.cornerRadius = 16

        continueButtonContainer.alpha = 0
        nameTextField.delegate = self
    }

    // MARK: - Connected Badge

    private func setupConnectedBadge() {
        let badge = buildConnectedBadge()
        badge.alpha = 0
        connectedView.addSubview(badge)

        NSLayoutConstraint.activate([
            badge.centerXAnchor.constraint(equalTo: successAnimationContainer.centerXAnchor),
            badge.topAnchor.constraint(equalTo: successAnimationContainer.bottomAnchor, constant: -10),
            badge.heightAnchor.constraint(equalToConstant: 24)
        ])

        connectedBadgeView = badge
    }

    private func buildConnectedBadge() -> UIView {
        let green = UIColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1)

        let badge = UIView()
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.backgroundColor = green.withAlphaComponent(0.15)
        badge.layer.borderColor = green.cgColor
        badge.layer.borderWidth = 1
        badge.layer.cornerRadius = 12

        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.backgroundColor = green
        dot.layer.cornerRadius = 4

        // Pulsing glow on the dot
        let pulse = CABasicAnimation(keyPath: "opacity")
        pulse.fromValue = 1.0
        pulse.toValue = 0.3
        pulse.duration = 0.9
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        dot.layer.add(pulse, forKey: "pulse")

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Connected"
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = green

        badge.addSubview(dot)
        badge.addSubview(label)

        NSLayoutConstraint.activate([
            dot.widthAnchor.constraint(equalToConstant: 8),
            dot.heightAnchor.constraint(equalToConstant: 8),
            dot.leadingAnchor.constraint(equalTo: badge.leadingAnchor, constant: 10),
            dot.centerYAnchor.constraint(equalTo: badge.centerYAnchor),

            label.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 5),
            label.trailingAnchor.constraint(equalTo: badge.trailingAnchor, constant: -10),
            label.centerYAnchor.constraint(equalTo: badge.centerYAnchor)
        ])

        return badge
    }

    // MARK: - Settings Button (shown only for permission errors)

    private func setupOpenSettingsButton() {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Open Settings", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(white: 1, alpha: 0.15)
        btn.layer.cornerRadius = 10
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        btn.layer.borderWidth = 1
        btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        btn.alpha = 0
        btn.addTarget(self, action: #selector(openSettingsTapped(_:)), for: .touchUpInside)

        errorView.addSubview(btn)

        NSLayoutConstraint.activate([
            btn.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            btn.topAnchor.constraint(equalTo: tryAgainButtonContainer.bottomAnchor, constant: 14),
            btn.heightAnchor.constraint(equalToConstant: 40)
        ])

        openSettingsButton = btn
    }

    // MARK: - Lottie Setup

    private func setupAnimations() {
        connectingAnimation = createLottie(named: "loading_spinner", looping: true)
        successAnimation   = createLottie(named: "success_check",    looping: false)
        audioWaveAnimation = createLottie(named: "audio_wave",        looping: true)

        if let v = connectingAnimation { embed(animation: v, in: connectingAnimationContainer) }
        if let v = successAnimation    { embed(animation: v, in: successAnimationContainer) }
        if let v = audioWaveAnimation  { embed(animation: v, in: audioLevelContainer) }
    }

    private func createLottie(named name: String, looping: Bool) -> LottieAnimationView {
        let view = LottieAnimationView(name: name)
        view.loopMode = looping ? .loop : .playOnce
        view.contentMode = .scaleAspectFit
        return view
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

    // MARK: - ViewModel Binding

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            DispatchQueue.main.async {
                self?.render(state: state)
            }
        }
    }

    // MARK: - State Rendering

    private func render(state: LandingState) {
        UIView.transition(
            with: contentContainer,
            duration: 0.35,
            options: [.transitionCrossDissolve, .allowUserInteraction],
            animations: { self.apply(state: state) }
        )
    }

    private func apply(state: LandingState) {
        idleView.isHidden = true
        connectingView.isHidden = true
        connectedView.isHidden = true
        errorView.isHidden = true

        connectingAnimation?.stop()
        successAnimation?.stop()
        audioWaveAnimation?.stop()
        audioWaveAnimation?.transform = .identity
        LiveKitManager.shared.onAudioLevel = nil

        switch state {

        case .idle:
            idleView.isHidden = false
            setStartButton(enabled: true)
            connectedBadgeView?.alpha = 0
            continueButtonContainer.alpha = 0

        case .connecting:
            connectingView.isHidden = false
            setStartButton(enabled: false)
            connectingAnimation?.play()

        case .connected:
            connectedView.isHidden = false
            continueButtonContainer.alpha = 0
            successAnimation?.loopMode = .playOnce
            successAnimation?.play { [weak self] finished in
                // Once the checkmark finishes, start the audio wave at gentle idle speed.
                if finished { self?.audioWaveAnimation?.play() }
            }
            showConnectedBadge()
            animateInContinueButton()
            startLiveAudioLevel()

        case .error(let message, let isPermissionError):
            errorView.isHidden = false
            setStartButton(enabled: true)
            errorMessageLabel.text = message
            configureErrorView(isPermissionError: isPermissionError)
        }
    }

    // MARK: - Connected State Helpers

    private func showConnectedBadge() {
        UIView.animate(withDuration: 0.4, delay: 0.2, options: .curveEaseOut) {
            self.connectedBadgeView?.alpha = 1
        }
    }

    private func animateInContinueButton() {
        // Start slightly scaled-down so the spring has something to animate from.
        continueButtonContainer.transform = CGAffineTransform(scaleX: 0.82, y: 0.82)
        UIView.animate(
            withDuration: 0.55,
            delay: 0.65,
            usingSpringWithDamping: 0.65,
            initialSpringVelocity: 0.6,
            options: []
        ) {
            self.continueButtonContainer.alpha = 1
            self.continueButtonContainer.transform = .identity
        }
    }

    private func startLiveAudioLevel() {
        // Play at a fixed medium speed — scale is the visual signal, not speed.
        audioWaveAnimation?.animationSpeed = 1.0
        // Start at a small idle scale; speaking will grow it.
        audioWaveAnimation?.transform = CGAffineTransform(scaleX: 0.42, y: 0.42)

        LiveKitManager.shared.onAudioLevel = { [weak self] level in
            guard let self else { return }
            // Scale: 0.42 (silence) → 1.15 (loud speech). This is impossible to miss.
            let scale = CGFloat(0.42 + Double(level) * 0.73)
            UIView.animate(
                withDuration: 0.08,
                delay: 0,
                options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState]
            ) {
                self.audioWaveAnimation?.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
    }

    // MARK: - Error State Helpers

    private func configureErrorView(isPermissionError: Bool) {
        if isPermissionError {
            errorTitleLabel.text = "Microphone Access Required"
            errorIconImageView.image = UIImage(named: "ic_mic")
            // Keep "Try Again" visible — user can tap it after enabling mic in Settings.
            tryAgainButtonContainer.isHidden = false
            UIView.animate(withDuration: 0.25) {
                self.openSettingsButton?.alpha = 1
            }
        } else {
            errorTitleLabel.text = "Connection Failed"
            errorIconImageView.image = UIImage(named: "ic_error")
            tryAgainButtonContainer.isHidden = false
            UIView.animate(withDuration: 0.25) {
                self.openSettingsButton?.alpha = 0
            }
        }
    }

    // MARK: - Start Button Animation

    private func setStartButton(enabled: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.startButtonContainer.alpha = enabled ? 1.0 : 0.5
            self.startButton.isEnabled = enabled
        }
    }

    // MARK: - Permission + Connection Flow

    /// Validates the name, then hands off directly to LiveKit.
    /// LiveKit's LocalAudioTrack.createTrack() triggers the system mic permission prompt.
    private func requestPermissionAndStart() {
        let name = nameTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !name.isEmpty else {
            // Stay on idle — just shake the field as a hint. No state transition.
            shakeTextField()
            return
        }
        nameTextField.resignFirstResponder()
        viewModel.startSession(identity: name)
    }

    private func shakeTextField() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.4
        animation.values = [-10, 10, -8, 8, -5, 5, 0]
        nameTextField.layer.add(animation, forKey: "shake")
    }

    // MARK: - IBActions

    @IBAction private func startTapped(_ sender: UIButton) {
        animateButtonPress(sender) { [weak self] in
            self?.requestPermissionAndStart()
        }
    }

    @IBAction private func tryAgainTapped(_ sender: UIButton) {
        animateButtonPress(sender) { [weak self] in
            guard let self else { return }
            self.viewModel.retry(identity: self.nameTextField.text ?? "")
        }
    }

    @IBAction private func continueTapped(_ sender: UIButton) {
        animateButtonPress(sender) { [weak self] in
            let roomVC = RoomViewController()
            self?.navigationController?.pushViewController(roomVC, animated: true)
        }
    }

    @IBAction private func disconnectTapped(_ sender: UIButton) {
        viewModel.disconnect()
    }

    @IBAction private func openSettingsTapped(_ sender: UIButton) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Button Press Animation

    private func animateButtonPress(_ button: UIButton, completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.10,
            animations: { button.superview?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95) },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.12, 
                    delay: 0.2,
                    usingSpringWithDamping: 0.6,
                    initialSpringVelocity: 0.8,
                    options: []
                ) {
                    button.superview?.transform = .identity
                } completion: { _ in
                    completion()
                }
            }
        )
    }
}

// MARK: - UITextFieldDelegate

extension LandingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        requestPermissionAndStart()
        return true
    }
}

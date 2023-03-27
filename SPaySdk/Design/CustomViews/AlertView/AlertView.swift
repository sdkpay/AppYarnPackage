//
//  AlertView.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 25.11.2022.
//

import UIKit
import AVFoundation

private extension CGFloat {
    static let imageWidth = 80.0
    static let topMargin = 52.0
    static let buttonsMargin = 32.0
    static let bottomMargin = 66.0
}

private extension TimeInterval {
    static let animationDuration: TimeInterval = 0.25
    static let completionDuration: TimeInterval = 4.25
}

final class AlertView: UIView {
    private var audioPlayer: AVAudioPlayer?
    
    private lazy var imageView = UIImageView()

    private lazy var alertTitle: UILabel = {
        let view = UILabel()
        view.font = .bodi3
        view.numberOfLines = 0
        view.textColor = .textPrimory
        view.textAlignment = .center
        return view
    }()
    
    private lazy var buttonsStack: UIStackView = {
        let view = UIStackView()
        view.spacing = .margin
        view.axis = .vertical
        view.alignment = .fill
        return view
    }()
    
    private var model: AlertViewModel

    init(with model: AlertViewModel) {
        self.model = model
        super.init(frame: .zero)
        configUI()
        completion()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func completion() {
        playFeedback()
        playSound()
        if model.buttons.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + .completionDuration) { [weak self] in
                self?.model.completion()
            }
        }
    }

    private func configUI() {
        imageView.image = model.image
        alertTitle.text = model.title

        for item in model.buttons {
            let button = DefaultButton(buttonAppearance: item.type)
            button.setTitle(item.title, for: .normal)
            button.addAction(item.action)
            buttonsStack.addArrangedSubview(button)
            
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: .defaultButtonHeight)
            ])
        }
        setupUI()
    }
    
    private func playSound() {
        guard let path = Bundle.sdkBundle.path(forResource: model.sound,
                                               ofType: nil) else { return }
        let url = URL(fileURLWithPath: path)
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func playFeedback() {
        UINotificationFeedbackGenerator().notificationOccurred(model.feedBack)
    }
    
    func setupUI() {
        isUserInteractionEnabled = true
        addSubview(imageView)
        addSubview(alertTitle)
        addSubview(buttonsStack)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: .imageWidth),
            imageView.heightAnchor.constraint(equalToConstant: .imageWidth)
        ])
        
        alertTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            alertTitle.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: .margin),
            alertTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .margin),
            alertTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.margin)
        ])
        
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonsStack.topAnchor.constraint(equalTo: alertTitle.bottomAnchor, constant: .buttonsMargin),
            buttonsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .margin),
            buttonsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.margin),
            buttonsStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

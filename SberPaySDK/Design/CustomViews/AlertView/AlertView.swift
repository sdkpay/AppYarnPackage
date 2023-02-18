//
//  AlertView.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 25.11.2022.
//

import UIKit
import AVFoundation

enum AlertState {
    case success
    case failure(text: String? = nil)
    
    var soundPath: String {
        switch self {
        case .success:
            return "poz.mp3"
        case .failure:
            return "neg.mp3"
        }
    }
}

private extension CGFloat {
    static let imageWidth = 80.0
}

private extension TimeInterval {
    static let animationDuration: TimeInterval = 0.25
    static let completionDuration: TimeInterval = 2.25
}

final class AlertView: UIView {
    private lazy var imageView = UIImageView()
    private var audioPlayer: AVAudioPlayer?
    private var state: AlertState?
    private var needButton = false

    private lazy var alertTitle: UILabel = {
        let view = UILabel()
        view.font = .bodi3
        view.numberOfLines = 0
        view.textColor = .textPrimory
        view.textAlignment = .center
        return view
    }()
    
    private lazy var alertStack: UIStackView = {
        let view = UIStackView()
        view.spacing = .margin
        view.axis = .vertical
        view.alignment = .center
        return view
    }()
    
    private lazy var button = DefaultButton(buttonAppearance: .info)

    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func config(buttonTitle: String?, with state: AlertState) {
        self.state = state
        backgroundColor = .backgroundPrimary

        switch state {
        case .success:
            imageView.image = .Common.success
            alertTitle.text = .Alert.alertPaySuccessTitle
        case .failure(let text):
            imageView.image = .Common.failure
            if let text = text {
                alertTitle.text = text
            } else {
                alertTitle.text = String(stringLiteral: .Alert.alertErrorMainTitle)
            }
        }
        if alertTitle.text != nil {
            alertStack.addArrangedSubview(alertTitle)
        }

        if let buttonTitle = buttonTitle {
            needButton = true
            button.setTitle(buttonTitle, for: .normal)
            alertStack.addArrangedSubview(button)
        }

        UIView.animate(withDuration: .animationDuration,
                       delay: 0) { [weak self] in
            guard let self = self else { return }
            self.alpha = 1
        }
    }
    
    func show(animate: Bool, with completion: @escaping Action) {
        if animate {
            UIView.animate(withDuration: .animationDuration,
                           delay: 0) { [weak self] in
                guard let self = self else { return }
                self.alpha = 1
            } completion: { [weak self] _ in
                self?.showCompleted(with: completion)
            }
        } else {
            showCompleted(with: completion)
        }
    }
    
    private func showCompleted(with completion: @escaping Action) {
        if let state = state {
            self.playFeedback(for: state)
            self.playSound(for: state)
        }
        if needButton {
            button.addAction(completion)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .completionDuration,
                                          execute: {
                completion()
            })
        }
    }
    
    private func playSound(for state: AlertState) {
        guard let path = Bundle.sdkBundle.path(forResource: state.soundPath,
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
    
    private func playFeedback(for state: AlertState) {
        var feedBack: UINotificationFeedbackGenerator.FeedbackType
        switch state {
        case .success:
            feedBack = .success
        case .failure:
            feedBack = .warning
        }
        UINotificationFeedbackGenerator().notificationOccurred(feedBack)
    }
    
    func setupUI() {
        isUserInteractionEnabled = true
        alpha = 0

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: .imageWidth),
            imageView.heightAnchor.constraint(equalToConstant: .imageWidth)
        ])

        addSubview(alertStack)
        alertStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            alertStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            alertStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            alertStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .margin),
            alertStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.margin)
        ])
        alertStack.addArrangedSubview(imageView)
    }
}

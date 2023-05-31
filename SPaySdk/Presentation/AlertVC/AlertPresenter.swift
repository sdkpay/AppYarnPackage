//
//  AlertPresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 30.05.2023.
//

import AVFAudio
import UIKit

private extension TimeInterval {
    static let animationDuration: TimeInterval = 0.25
    static let completionDuration: TimeInterval = 4.25
}

protocol AlertPresenting {
    func viewDidLoad()
}

final class AlertPresenter: AlertPresenting {
    private var audioPlayer: AVAudioPlayer?

    weak var view: (IAlertVC & ContentVC)?

    private var model: AlertViewModel
    
    init(with model: AlertViewModel) {
        self.model = model
    }
    
    func viewDidLoad() {
        view?.configView(with: model)
        completeConfig()
    }
    
    private func completeConfig() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .animationDuration) { [weak self] in
            self?.playFeedback()
            self?.playSound()
        }
        if model.buttons.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + .completionDuration) { [weak self] in
                self?.model.completion()
            }
        }
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
}

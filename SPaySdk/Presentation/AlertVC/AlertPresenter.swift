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
    func buttonTapped(item: AlertButtonModel)
}

final class AlertPresenter: AlertPresenting {
    weak var view: (IAlertVC & ContentVC)?

    private var audioPlayer: AVAudioPlayer?
    private var model: AlertViewModel
    private var feedbackDispatchWorkItem: DispatchWorkItem?
    private var completionDispatchWorkItem: DispatchWorkItem?
    private var liveCircleManager: LiveCircleManager
    
    init(with model: AlertViewModel,
         liveCircleManager: LiveCircleManager) {
        self.model = model
        self.liveCircleManager = liveCircleManager
    }
    
    func viewDidLoad() {
        view?.configView(with: model)
        completeConfig()
    }
    
    func buttonTapped(item: AlertButtonModel) {
        switch item.type {
        case .full, .info:
            view?.contentNavigationController?.popViewController(animated: true, completion: {
                item.action()
            })
        case .cancel:
            item.action()
        case .clear:
            item.action()
            view?.contentNavigationController?.popViewController(animated: true)
        }
    }

    private func completeConfig() {
        let feedbackDispatchWorkItem = DispatchWorkItem {
            self.playFeedback()
            self.playSound()
        }

        let completionDispatchWorkItem = DispatchWorkItem {
            if self.model.buttons.isEmpty {
                self.model.completion()
            }
        }

        self.completionDispatchWorkItem = completionDispatchWorkItem
        self.feedbackDispatchWorkItem = feedbackDispatchWorkItem

        DispatchQueue.main.asyncAfter(deadline: .now() + .animationDuration,
                                      execute: feedbackDispatchWorkItem)

        DispatchQueue.main.asyncAfter(deadline: .now() + .completionDuration,
                                      execute: completionDispatchWorkItem)
        
        liveCircleManager.closeWithGesture = {
            self.cancelFeedback()
        }
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    private func cancelFeedback() {
        completionDispatchWorkItem?.cancel()
        feedbackDispatchWorkItem?.cancel()
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

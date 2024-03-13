//
//  AlertPresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 30.05.2023.
//

import AVFAudio
import UIKit

typealias AlertResultAction = (AlertResult) -> Void

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
    private var alertResultAction: AlertResultAction?
    
    init(with model: AlertViewModel,
         liveCircleManager: LiveCircleManager,
         alertResultAction: @escaping AlertResultAction) {
        self.model = model
        self.alertResultAction = alertResultAction
        self.liveCircleManager = liveCircleManager
    }
    
    func viewDidLoad() {
        view?.configView(with: model)
        completeConfig()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(cancelFeedback),
                                               name: .closeSDKNotification,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .closeSDKNotification, object: nil)
        SBLogger.log(.stop(obj: self))
    }
    
    func buttonTapped(item: AlertButtonModel) {
        if !model.isFailure {
            self.alertResultAction?(.cancel)
            return
        }
        DispatchQueue.main.async {
                self.view?.contentNavigationController?.popViewController(animated: true, completion: {
                    
                    self.alertResultAction?(item.neededResult)
                    item.action?()
                })
        }
    }

    private func completeConfig() {
        
        let feedbackDispatchWorkItem = DispatchWorkItem {
            self.playFeedback()
            self.playSound()
        }

        let completionDispatchWorkItem = DispatchWorkItem {
            if self.model.buttons.isEmpty {
                
                self.alertResultAction?(.cancel)
                self.alertResultAction = nil
            }
        }

        self.completionDispatchWorkItem = completionDispatchWorkItem
        self.feedbackDispatchWorkItem = feedbackDispatchWorkItem

        DispatchQueue.main.asyncAfter(deadline: .now() + .animationDuration,
                                      execute: feedbackDispatchWorkItem)

        DispatchQueue.main.asyncAfter(deadline: .now() + .completionDuration,
                                      execute: completionDispatchWorkItem)
        
        let afterTime = model.isFailure ? 0.5 : 0
        DispatchQueue.main.asyncAfter(deadline: .now() + .animationDuration + afterTime) {
            self.view?.playAnimation()
        }
        
        liveCircleManager.closeWithGesture = {
            self.cancelFeedback()
        }
    }
    
    @objc
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

//
//  AlertPresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 30.05.2023.
//

import Foundation
import AVFAudio

struct AlertButtonModel {
    let title: String
    let type: DefaultButtonAppearance
    let action: Action
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
    }
}

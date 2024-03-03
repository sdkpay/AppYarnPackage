//
//  ConnectInfoModulePresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 02.03.2024.
//

import Foundation
import UIKit

protocol ConnectInfoModulePresenting: NSObject {
    
    func viewDidLoad()
    
    var view: (IConnectInfoModuleVC & ModuleVC)? { get set }
}

final class ConnectInfoModulePresenter: NSObject, ConnectInfoModulePresenting {
 
    weak var view: (IConnectInfoModuleVC & ModuleVC)?

    func viewDidLoad() {
        
        configViews()
    }
    
    private func configViews() {
    
        view?.setInfoText(ConfigGlobal.localization?.connectTitle ?? "")
    }
}

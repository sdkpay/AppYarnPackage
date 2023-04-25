//
//  LoggableVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 31.03.2023.
//

import UIKit

class LoggableVC: UIViewController {
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        #if SDKDEBUG
        if motion == .motionShake {
            let logModule = LogAssembly().createModule()
            present(logModule, animated: true)
        }
        #else
        super.motionEnded(motion, with: event)
        #endif
    }
}

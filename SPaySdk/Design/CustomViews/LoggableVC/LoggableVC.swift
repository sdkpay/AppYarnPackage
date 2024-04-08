//
//  LoggableVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 31.03.2023.
//

import UIKit

class LoggableVC: UIViewController {
    
    private var loggableWindow: UIWindow?
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        #if SDKDEBUG
        if motion == .motionShake {
            
            DispatchQueue.main.async {
                
                let logModule = LogAssembly().createModule(completion: { [weak self] in
                    self?.loggableWindow?.isHidden = true
                    self?.loggableWindow = nil
                })
                
                let root = UIViewController(nibName: nil, bundle: nil)
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                self.loggableWindow = window
                window.windowLevel = .alert + 2
                window.rootViewController = root
                window.makeKeyAndVisible()
                
                root.present(logModule, animated: true)
            }
        }
        #else
        super.motionEnded(motion, with: event)
        #endif
    }
}

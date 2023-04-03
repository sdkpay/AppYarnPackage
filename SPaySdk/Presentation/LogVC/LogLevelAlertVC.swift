//
//  LogLevelAlertVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 03.04.2023.
//

import UIKit

private extension String {
    static let allTitle = "Весь лог"
}

final class LogLevelAlertVC: UIAlertController {
    private var completion: (DebugLogLevel?) -> Void
    
    init(with completion: @escaping (DebugLogLevel?) -> Void) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
    }
    
    private func setupActions() {
        for level in DebugLogLevel.allCases {
            addAction(.init(title: level.rawValue, style: .default, handler: { _ in
                self.completion(level)
                self.dismiss(animated: true)
            }))
        }
        addAction(.init(title: .allTitle, style: .default, handler: { _ in
            self.completion(nil)
            self.dismiss(animated: true)
        }))
    }
}

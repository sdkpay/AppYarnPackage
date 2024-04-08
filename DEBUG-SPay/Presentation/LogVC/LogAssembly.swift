//
//  LogAssembly.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 30.03.2023.
//

import UIKit

final class LogAssembly {
    
    func createModule(completion: @escaping Action) -> UIViewController {
        
        guard let logPath = SBLogger.logPath else {
            assertionFailure("Неверный путь до файла логов: \(String(describing: SBLogger.logPath))")
            return UIViewController()
        }
        let contentView = moduleView(url: logPath, completion: completion)
        return contentView
    }

    private func moduleView(url: URL, completion: @escaping Action) -> LogVC {
        let view = LogVC(with: url, completion: completion)
        return view
    }
}

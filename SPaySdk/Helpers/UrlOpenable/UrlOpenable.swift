//
//  UrlOpenable.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 04.01.2024.
//

import UIKit

protocol UrlOpenable {
    
    func open(_ url: URL) async -> Bool
}

extension UrlOpenable {

    @MainActor
    func open(_ url: URL) async -> Bool {
        
        SBLogger.log(level: .debug(level: .lifeCycle), "➡️ Open url: \(url.absoluteString)")
        
        return await UIApplication.shared.open(url)
    }
}

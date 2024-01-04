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
        
        await UIApplication.shared.open(url)
    }
}

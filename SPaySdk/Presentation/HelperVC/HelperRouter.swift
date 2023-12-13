//
//  HelperRouter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 11.12.2023.
//

import UIKit

protocol HelperRouting {
    
    func openUrl(url: URL)
}

final class HelperRouter: HelperRouting {
    
    @MainActor
    func openUrl(url: URL) {
        UIApplication.shared.open(url)
    }
}

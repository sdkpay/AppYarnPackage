//
//  KeyboardManager.swift
//  SPaySdk
//
//  Created by Арсений on 15.08.2023.
//

import Foundation


final class KeyboardManagerAssembly: Assembly {
    func register(in container: LocatorService) {
        container.register {
            let service: KeyboardManager = DefaultKeyboardManager()
            return service
        }
    }
}

protocol KeyboardManager {
    func getKeyboardHeight() -> CGFloat
}

final class DefaultKeyboardManager: KeyboardManager {
    func getKeyboardHeight() -> CGFloat {
        switch Device.current.diagonal {
        case 4, 4.7:
            return 260
        case 5.5:
            return 271
        case 5.8, 5.4, 6.7:
            return 336
        case 6.1:
            return 346
        default:
            return 320
        }
    }
}

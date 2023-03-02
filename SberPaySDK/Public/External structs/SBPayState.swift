//
//  SBPayState.swift
//  SberPaySDK
//
//  Created by Ипатов Александр Станиславович on 02.03.2023.
//

import Foundation

@objc
public enum SBPayState: Int {
    case success = 0
    case waiting = 1
    case error = 2
}

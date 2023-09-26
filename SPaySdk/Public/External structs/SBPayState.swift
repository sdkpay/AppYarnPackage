//
//  SBPayState.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 02.03.2023.
//

import Foundation

@objc
public enum SPayState: Int {
    case success = 0
    case waiting
    case cancel
    case error
}

//
//  Result+Success.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 29.05.2023.
//

import Foundation

extension Result where Success == Void {
    static var success: Result {
        return .success(())
    }
}

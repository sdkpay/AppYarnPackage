//
//  SHelperConfig.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 22.11.2023.
//

import Foundation

@objc(SConfig)
public final class SBHelperConfig: NSObject {
    
    var sbp: Bool
    var creditCard: Bool

    @objc
    public init(sbp: Bool = true, creditCard: Bool = true) {
        self.sbp = sbp
        self.creditCard = creditCard
    }
}

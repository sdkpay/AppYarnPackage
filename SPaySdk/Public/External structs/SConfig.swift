//
//  SConfig.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 22.11.2023.
//

import Foundation

@objc(SConfig)
public final class SConfig: NSObject {
    
    let bnplPlan: Bool
    
    @objc
    public init(bnplPlan: Bool = true) {
        self.bnplPlan = bnplPlan
    }
}

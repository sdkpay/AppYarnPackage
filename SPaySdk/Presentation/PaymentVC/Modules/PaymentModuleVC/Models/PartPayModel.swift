//
//  PartPayModel.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 13.11.2023.
//

import Foundation

enum PaymentFeatureWidth {
    
    case long
    case square
    case estimated
}

struct PaymentFeatureModel: Hashable, AbstractCellModel {

    let iconViewURL: String?
    let title: String?
    let subTitle: String?
    let switchOn: Bool
    var switchNeed = true
    var width: PaymentFeatureWidth = .estimated
    
    func map<T>(type: T.Type) -> T? where T: Hashable {
        self as? T
    }
}

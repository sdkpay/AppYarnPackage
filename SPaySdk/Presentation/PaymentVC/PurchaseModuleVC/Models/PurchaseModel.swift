//
//  PurchaseModel.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 08.12.2023.
//

import Foundation

struct PurchaseModel: Hashable, AbstractCellModel {

    let title: String
    let subTitle: String?
    
    func map<T>(type: T.Type) -> T? where T: Hashable {
        self as? T
    }
}

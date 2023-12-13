//
//  CardModel.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 13.11.2023.
//

import Foundation

struct CardModel: Hashable, AbstractCellModel {

    let iconViewURL: String?
    let title: String?
    let subTitle: String?
    let needArrow: Bool
    
    func map<T>(type: T.Type) -> T? where T: Hashable {
        self as? T
    }
}

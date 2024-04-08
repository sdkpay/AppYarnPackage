//
//  HelperModelCell.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 05.12.2023.
//

import Foundation

struct HelperModelCell: Hashable, AbstractCellModel {

    let iconViewURL: String?
    let title: String?
    let subTitle: String?
    
    func map<T>(type: T.Type) -> T? where T: Hashable {
        self as? T
    }
}

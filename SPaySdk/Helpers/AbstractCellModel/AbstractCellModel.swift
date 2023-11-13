//
//  AbstractCellModel.swift
//  Crypto
//
//  Created by Ипатов Александр Станиславович on 12.10.2023.
//

import Foundation

protocol AbstractCellModel {
    
    func map<T: Hashable>(type: T.Type) -> T?
}

protocol SelfConfigCell {
    
    func config<U>(with model: U) where U: AbstractCellModel
}

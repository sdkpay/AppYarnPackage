//
//  BankModel.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 02.12.2022.
//

import Foundation

struct BankModel {
    var code: String?
    var state: String?

    init(dictionary: [String: String]) {
        self.code = dictionary["code"]
        self.state = dictionary["state"]
    }
}

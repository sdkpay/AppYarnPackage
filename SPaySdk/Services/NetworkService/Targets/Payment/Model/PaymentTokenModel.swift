//
//  PaymentTokenModel.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 28.01.2023.
//

import Foundation

struct PaymentTokenModel: Codable {
    let paymentToken: String
    let initiateBankInvoiceId: String?
}

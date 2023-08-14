//
//  MerchParamsValidator.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 14.08.2023.
//

import Foundation

enum MerchParamsValidator {
    static func validateSFullPaymentRequest(_ request: SFullPaymentRequest) -> String? {
        guard request.orderId.count == 32 else { return Strings.Merchant.Alert.Param.count("orderId", 32) }
        return nil
    }
    
    static func validateSBankInvoicePaymentRequest(_ request: SBankInvoicePaymentRequest) -> String? {
        guard request.bankInvoiceId.count == 32 else { return Strings.Merchant.Alert.Param.count("bankInvoiceId", 32) }
        return nil
    }
}

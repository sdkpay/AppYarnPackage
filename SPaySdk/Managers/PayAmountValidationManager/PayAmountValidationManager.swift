//
//  PayAmountValidationManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 04.12.2023.
//

import Foundation

enum PayAmountStatus {
    case enouth
    case onlyBnpl
    case notEnouth
}

final class PayAmountValidationManagerAssembly: Assembly {
    
    var type = ObjectIdentifier(PayAmountValidationManager.self)
    
    func register(in container: LocatorService) {
        container.register {
            let service: PayAmountValidationManager = DefaultPayAmountValidationManager(with: container.resolve(),
                                                                                        partPayService: container.resolve())
            return service
        }
    }
}

protocol PayAmountValidationManager {
    
    func checkWalletAmountEnouth() throws -> Bool
    func checkAmountSelectedTool(_ tool: PaymentToolInfo) throws -> PayAmountStatus
}

final class DefaultPayAmountValidationManager: PayAmountValidationManager {
    
    private let userService: UserService
    private let partPayService: PartPayService
    
    init(with userService: UserService,
         partPayService: PartPayService) {
        self.userService = userService
        self.partPayService = partPayService
    }
    
    func checkWalletAmountEnouth() throws -> Bool {
        
        guard let user = userService.user else { throw SDKError(.noData) }
        
        return try user.paymentToolInfo.contains(where: { try checkAmountSelectedTool($0) != .notEnouth })
    }
    
    func checkAmountSelectedTool(_ tool: PaymentToolInfo) throws -> PayAmountStatus {
        
        guard let user = userService.user else { throw SDKError(.noData) }
        
        if isEnouth(amount: user.orderAmount.amount, on: tool) {
            return .enouth
        }
        
        guard let amount = partPayService.bnplplan?.graphBnpl?.payments.first?.amount else { return .notEnouth }
        
        if isEnouth(amount: amount, on: tool) {
            return .onlyBnpl
        }
        
        return .notEnouth
    }
    
    private func isEnouth(amount: Int, on paymentToolInfo: PaymentToolInfo) -> Bool {
        
        amount <= paymentToolInfo.amountData.amountInt
    }
}

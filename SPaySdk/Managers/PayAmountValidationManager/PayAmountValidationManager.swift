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
    
    func checkWalletAmountEnouth() throws -> PayAmountStatus
    func checkAmountSelectedTool(_ tool: PaymentTool) throws -> PayAmountStatus
}

final class DefaultPayAmountValidationManager: PayAmountValidationManager {
    
    private let userService: UserService
    private let partPayService: PartPayService
    
    init(with userService: UserService,
         partPayService: PartPayService) {
        self.userService = userService
        self.partPayService = partPayService
    }
    
    func checkWalletAmountEnouth() throws -> PayAmountStatus {
        
        guard let user = userService.user else { throw SDKError(.noData) }
        
        var state = PayAmountStatus.notEnouth
        
        for tool in user.paymentToolInfo.paymentTool {
            if try checkAmountSelectedTool(tool) == .enouth {
                state = .enouth
                break
            } else if try checkAmountSelectedTool(tool) == .onlyBnpl {
                state = .onlyBnpl
                break
            }
        }
        
        return state
    }
    
    func checkAmountSelectedTool(_ tool: PaymentTool) throws -> PayAmountStatus {
        
        guard let user = userService.user else { throw SDKError(.noData) }
        
        if isEnouth(amount: user.orderInfo.orderAmount.amount, on: tool) {
            return .enouth
        }
        
        guard let amount = partPayService.bnplplan?.graphBnpl?.parts.first?.amount else { return .notEnouth }
        
        if isEnouth(amount: amount, on: tool) {
            return .onlyBnpl
        }
        
        return .notEnouth
    }
    
    private func isEnouth(amount: Int, on paymentToolInfo: PaymentTool) -> Bool {
        
        amount <= paymentToolInfo.amountData.amount
    }
}

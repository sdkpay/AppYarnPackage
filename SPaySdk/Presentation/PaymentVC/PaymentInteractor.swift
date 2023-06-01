//
//  PaymentInteractor.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 29.05.2023.
//

import Foundation

//protocol PaymentInteracting {
//    var payServices: [PayService] { get }
//    var selectedCard: PaymentToolInfo? { get }
//    var bnplModel: BnplModel? { get }
//    var user: User? { get }
//    var bnplplanSelected: Bool { get }
//    func pay()
//}
//
//final class PaymentInteractor: PaymentInteracting {
//    private var paymentService: PaymentService
//    private var partPayService: PartPayService
//    private var userService: UserService
//    private var sdkManager: SDKManager
//    
//    var payServices: [PayService] {
//        var services: [PayService] = []
//        for service in PayService.allCases {
//            if serviceAvalible(service: service) {
//                services.append(service)
//            }
//        }
//        return services
//    }
//    
//    var selectedCard: PaymentToolInfo? {
//        userService.selectedCard
//    }
//    
//    var user: User? {
//        userService.user
//    }
//    
//    var bnplplanSelected: Bool {
//        partPayService.bnplplanSelected
//    }
//    
//    var bnplModel: BnplModel? {
//        partPayService.bnplplan
//    }
//    
//    init(paymentService: PaymentService,
//         partPayService: PartPayService,
//         sdkManager: SDKManager,
//         userService: UserService) {
//        self.userService = userService
//        self.sdkManager = sdkManager
//        self.paymentService = paymentService
//        self.partPayService = partPayService
//    }
//    
//    private func pay() {
//        guard let paymentId = userService.selectedCard?.paymentId else { return }
//        paymentService.tryToPay(paymentId: paymentId,
//                                isBnplEnabled: partPayService.bnplplanSelected) { [weak self] result in
//            switch result {
//            case .success:
//                print("")
//            case .failure(let error):
//                print("")
//            }
//        }
//    }
//    
//    private func getPaymentToken() {
//        partPayService.bnplplanSelected = false
//        partPayService.setUserEnableBnpl(false, enabledLevel: .server)
//        
//        guard let paymentId = userService.selectedCard?.paymentId else { return }
//        paymentService.tryToGetPaymenyToken(paymentId: paymentId,
//                                            isBnplEnabled: false) { result in
//            switch result {
//            case .success:
//                print("")
//            case .failure(let failure):
//                print(failure)
//            }
//        }
//    }
//
//    private func serviceAvalible(service: PayService) -> Bool {
//        switch service {
//        case .pay:
//            return true
//        case .partPay:
//           return partPayService.bnplplan != nil && partPayService.bnplplanEnabled
//        }
//    }
//    
//}

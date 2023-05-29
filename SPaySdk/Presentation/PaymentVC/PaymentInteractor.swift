//
//  PaymentInteractor.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 29.05.2023.
//

import Foundation

//protocol PaymentInteracting {
//    func pay()
//}
//
//final class PaymentInteractor: PaymentInteracting {
//    private var partPayService: PartPayService
//    private var paymentService: PaymentService
//    private var userService: UserService
// 
//    init(paymentService: PaymentService,
//         partPayService: PartPayService,
//         userService: UserService) {
//        self.paymentService = paymentService
//        self.partPayService = partPayService
//        self.userService = userService
//    }
//
////    func pay() {
////        guard let paymentId = userService.selectedCard?.paymentId else { return }
////        paymentService.tryToPay(paymentId: paymentId,
////                                isBnplEnabled: partPayService.bnplplanSelected) { [weak self] error in
////            if let error = error {
////
////            } else {
////
////            }
////        }
//    }
//
//private func pay() {
//    view?.userInteractionsEnabled = false
//    DispatchQueue.main.async {
//        self.view?.hideAlert()
//        self.view?.showLoading(with: .Loading.tryToPayTitle)
//    }
//    guard let paymentId = userService.selectedCard?.paymentId else { return }
//    paymentService.tryToPay(paymentId: paymentId,
//                            isBnplEnabled: partPayService.bnplplanSelected) { [weak self] error in
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//            self.view?.hideLoading()
//        }
//        self?.view?.userInteractionsEnabled = true
//        if let error = error {
//            self?.validatePayError(error)
//        } else {
//            self?.alertService.show(on: self?.view, type: .paySuccess(completion: {
//                self?.view?.dismiss(animated: true, completion: {
//                    self?.sdkManager.completionPay(with: .success)
//                })
//            }))
//        }
//    }
//}

//
//  SDKManager.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 30.11.2022.
//

import UIKit

protocol SDKManager {
    var request: SBPaymentTokenRequest? { get }
    func config(request: SBPaymentTokenRequest,
                completion: @escaping PaymentTokenCompletion)
    func tryToAuth(completion: @escaping (SDKError?) -> Void)
    func completionWithError(error: SDKError)
    var selectedBank: BankApp? { get }
    func removeSavedBank()
    func selectBank(_ app: BankApp?)
}

final class DefaultSDKManager: SDKManager {
    private var completion: PaymentTokenCompletion?
    private(set) var request: SBPaymentTokenRequest?
    private var authCompletion: ((SDKError?) -> Void)?
    
    private let network: NetworkService
    private let analytics: AnalyticsService
    private var authService: AuthService
    
    init(network: NetworkService,
         authService: AuthService,
         analytics: AnalyticsService) {
        self.network = network
        self.authService = authService
        self.analytics = analytics
    }
    
    func config(request: SBPaymentTokenRequest,
                completion: @escaping PaymentTokenCompletion) {
        self.request = request
        self.completion = completion
    }

    func tryToAuth(completion: @escaping (SDKError?) -> Void) {
        network.request(AuthTarget.getSessionId,
                        to: AuthModel.self) { [weak self] result in
            switch result {
            case .success(let result):
                self?.authWithSbol(authModel: result,
                                   completion: completion)
            case .failure(let error):
                completion(error)
                self?.completionWithError(error: error)
            }
        }
    }
    
    var selectedBank: BankApp? {
        authService.selectedBank
    }
    
    func selectBank(_ app: BankApp?) {
        authService.selectedBank = app
    }
    
    func removeSavedBank() {
        authService.removeSavedBank()
    }
    
    func completionWithError(error: SDKError) {
        let responce = SBPaymentTokenResponse()
        responce.error = SBPError(errorState: error)
        completion?(responce)
    }
    
    private func authWithSbol(authModel: AuthModel,
                              completion: @escaping (SDKError?) -> Void) {
        authService.tryToAuth(with: authModel) { [weak self] result in
            switch result {
            case .success(_):
                completion(nil)
            case .failure(let error):
                completion(error)
                self?.completionWithError(error: error)
            }
        }
    }
}

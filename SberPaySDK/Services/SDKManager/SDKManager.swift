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
    
    private let networkService: NetworkService
    private let analytics: AnalyticsService
    private var authService: AuthService
    
    init(networkService: NetworkService,
         authService: AuthService,
         analytics: AnalyticsService) {
        self.networkService = networkService
        self.authService = authService
        self.analytics = analytics
    }
    
    func config(request: SBPaymentTokenRequest,
                completion: @escaping PaymentTokenCompletion) {
        self.request = request
        self.completion = completion
    }

    func tryToAuth(completion: @escaping (SDKError?) -> Void) {
        networkService.request(AuthTarget.getSessionId) { [weak self] result in
            switch result {
            case .success():
                self?.authWithSbol(completion: completion)
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
    
    private func authWithSbol(completion: @escaping (SDKError?) -> Void) {
        guard let request = request else { return }
        authService.tryToAuth(with: request) { [weak self] result in
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

//
//  ChallengePresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 22.11.2023.
//

import UIKit

protocol ChallengePresenting {
    func viewDidLoad()
    func infoAlertTapped()
    func confirmTapped()
    func cancelTapped()
}

final class ChallengePresenter: ChallengePresenting {
    
    weak var view: (IChallengeVC & ContentVC)?

    private let analytics: AnalyticsService
    private let completion: (SecureChallengeResolution) -> Void
    private let router: ChallengeRouter
    private let completionManager: CompletionManager
    private let secureChallengeService: SecureChallengeService
    private let bankAppManager: BankAppManager
    
    init(_ router: ChallengeRouter,
         completionManager: CompletionManager,
         secureChallengeService: SecureChallengeService,
         bankAppManager: BankAppManager,
         analytics: AnalyticsService,
         completion: @escaping (SecureChallengeResolution) -> Void) {
        self.analytics = analytics
        self.router = router
        self.completion = completion
        self.secureChallengeService = secureChallengeService
        self.completionManager = completionManager
        self.bankAppManager = bankAppManager
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    func infoAlertTapped() {
        
        Task {
            await view?.showLoading()
            try? await secureChallengeService.sendChallengeResult(resolution: .confirmedFraud)

            guard let bankUrl = bankAppManager.selectedBank?.utilLink else {
                await MainActor.run { completionManager.dismissCloseAction(view) }
                return
            }
            guard let cybercabinetURLIOS = secureChallengeService.fraudMonСheckResult?.formParameters?.cybercabinetUrlIOS else {
                await MainActor.run { completionManager.dismissCloseAction(view) }
                return
            }
            
            guard let link = URL(string: bankUrl + cybercabinetURLIOS) else { return }
            
            await MainActor.run { completionManager.dismissCloseAction(view) }
            await router.openUrl(url: link)
        }
    }
    
    func viewDidLoad() {
        let params = secureChallengeService.fraudMonСheckResult?.formParameters
        
        view?.configView(header: params?.header,
                         subtitle: params?.text,
                         info: params?.buttonInformText,
                         mainButton: params?.buttonConfirmText,
                         cancelButton: params?.buttonDeclineText)
    }
    
    @MainActor 
    func confirmTapped() {
        self.view?.contentNavigationController?.popViewController(animated: false, completion: {
            self.completion(.confirmedGenuine)
        })
    }
    
    func cancelTapped() {
        completionManager.dismissCloseAction(view)
    }
}

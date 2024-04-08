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
    
    private func getViewName() {
        switch secureChallengeService.fraudMonСheckResult?.secureChallengeFactor {
            
        case .none:
            view?.analyticsName = .None
        case .hint:
            view?.analyticsName = .ReviewHintView
        case .sms:
            view?.analyticsName = .OtpReviewView
        }
    }
    
    func infoAlertTapped() {
        
        Task {
            await view?.showLoading()
            try? await secureChallengeService.sendChallengeResult(resolution: .confirmedFraud)

            guard let cybercabinetURLIOS = secureChallengeService.fraudMonСheckResult?.formParameters?.cybercabinetUrlIOS else {
                await MainActor.run { completionManager.dismissCloseAction(view) }
                return
            }
            
            guard let link = bankAppManager.configUrl(path: cybercabinetURLIOS, type: .util) else {
                await MainActor.run { completionManager.dismissCloseAction(view) }
                return
            }
            
            await MainActor.run { completionManager.dismissCloseAction(view) }
            
            let isOpened = await router.open(link)
            
            if !isOpened {
                
                await router.presentBankAppPicker()
                self.infoAlertTapped()
            }
        }
    }
    
    func viewDidLoad() {
        getViewName()
        
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
        
        if secureChallengeService.fraudMonСheckResult?.secureChallengeFactor == .hint {
            
            Task {
                try? await secureChallengeService.sendChallengeResult(resolution: .unknown)
            }
        }
    }
}

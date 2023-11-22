//
//  ChallengePresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 22.11.2023.
//

import UIKit

protocol ChallengePresenting {
    func viewDidLoad()
}

final class ChallengePresenter: ChallengePresenting {
    weak var view: (IChallengeVC & ContentVC)?

    private let analytics: AnalyticsService
    
    private let router: ChallengeRouter
    private let completionManager: CompletionManager
    private let secureChallengeService: SecureChallengeService
    
    init(_ router: ChallengeRouter,
         completionManager: CompletionManager,
         secureChallengeService: SecureChallengeService,
         analytics: AnalyticsService) {
        self.analytics = analytics
        self.router = router
        self.secureChallengeService = secureChallengeService
        self.completionManager = completionManager
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    func viewDidLoad() {
        let params = secureChallengeService.fraudMonСheckResult?.formParameters
        
        view?.configView(header: params?.header,
                         subtitle: params?.text,
                         info: params?.buttonInformText,
                         mainButton: params?.buttonСonfirmText,
                         cancelButton: Strings.Cancel.title)
    }
}

//
//  PartPayPresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 14.04.2023.
//

import UIKit
import Combine

protocol PartPayPresenting {
    func acceptButtonTapped()
    func backButtonTapped()
}

final class PartPayPresenter: PartPayPresenting {
    
    weak var view: (IPartPayVC & ContentVC)?
    
    var partsCount: Int {
        partPayService.bnplplan?.graphBnpl?.parts.count ?? 0
    }
    
    private var partPayService: PartPayService
    private let router: PartPayRouter
    private let timeManager: OptimizationCheсkerManager
    private let analytics: AnalyticsService
    private var partPaySelected: Action
    private var isSelected = true
    private var screenEvents = [AnalyticsKey.view: AnlyticsScreenEvent.PartPayVC.rawValue]
    private var cancellable = Set<AnyCancellable>()
    
    var partPayModule: ModuleVC
    
    init(_ router: PartPayRouter,
         partPayService: PartPayService,
         partPayModule: ModuleVC,
         timeManager: OptimizationCheсkerManager,
         analytics: AnalyticsService,
         partPaySelected: @escaping Action) {
        self.partPayService = partPayService
        self.router = router
        self.analytics = analytics
        self.timeManager = timeManager
        self.partPayModule = partPayModule
        self.partPaySelected = partPaySelected
        self.timeManager.startTraking()
    }
    
    func viewDidLoad() {
        setSubscribers()
    }
    
    private func setSubscribers() {
        
        partPayService.bnplCheckAcceptedPublisher
            .receive(on: DispatchQueue.main)
            .sink { value in
                self.view?.setButtonEnabled(value: value)
            }
            .store(in: &cancellable)
    }
    
    func acceptButtonTapped() {
        analytics.sendEvent(.TouchConfirmedByUser,
                            with: [.view: AnlyticsScreenEvent.PartPayVC.rawValue])
        partPayService.bnplplanSelected = true
        partPaySelected()
        DispatchQueue.main.async {
            self.view?.contentNavigationController?.popViewController(animated: true)
        }
    }
    
    func backButtonTapped() {
        analytics.sendEvent(.TouchDeclinedByUser,
                            with: [.view: AnlyticsScreenEvent.PartPayVC.rawValue])
        partPayService.bnplplanSelected = false
        partPaySelected()
        DispatchQueue.main.async {
            self.view?.contentNavigationController?.popViewController(animated: true)
        }
    }
}

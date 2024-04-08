//
//  HintsPaymentModulePresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 04.03.2024.
//

import UIKit
import Combine

final class HintsPaymentModulePresenter: NSObject, HintsModulePresenting {
    
    weak var view: (IHintsModuleVC & ModuleVC)?
    private var payAmountValidationManager: PayAmountValidationManager
    private let userService: UserService
    private var cancellable = Set<AnyCancellable>()
    
    init(userService: UserService,
         payAmountValidationManager: PayAmountValidationManager) {
        self.userService = userService
        self.payAmountValidationManager = payAmountValidationManager
        super.init()
    }
    
    func viewDidLoad() {
        setupSubscribers()
        setHints()
    }
    
    private func setupSubscribers() {
        
        userService.selectedCardPublisher
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.setHints()
            }
            .store(in: &cancellable)
    }
    
    private func setHints() {
        
        view?.setHints(with: hintsText)
    }
    
    private var hintsText: [String] {
        
        guard let tool = userService.selectedCard else { return [] }
        
        var hints = [String]()
        
        if let connectHint = connectIfNeeded() {
            
            hints.append(connectHint)
        }
        
        let payAmountStatus = try? payAmountValidationManager.checkAmountSelectedTool(tool)
        
        switch payAmountStatus {
            
        case .enouth, .none:
            
            return hints
        case .onlyBnpl:
            
            hints.append(Strings.Hints.Bnpl.title)
        case .notEnouth:
            
            hints.append(Strings.Hints.NotEnouth.title)
        }
        
        return hints
    }
    
    private func connectIfNeeded() -> String? {
        
        guard let merchantInfo = userService.user?.merchantInfo else { return nil }
        guard merchantInfo.bindingIsNeeded else { return nil }
        
        return merchantInfo.bindingSafeText
    }
}

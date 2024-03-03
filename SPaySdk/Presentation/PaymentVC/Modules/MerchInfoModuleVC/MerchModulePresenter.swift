//
//  MerchModulePresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 02.03.2024.
//

import Foundation
import UIKit

protocol MerchInfoModulePresenting {
    
    func profileButtonTapped()
    func viewDidLoad()
    
    var view: (IMerchInfoModuleVC & ModuleVC)? { get set }
}

final class MerchInfoModulePresenter: NSObject, MerchInfoModulePresenting {
    
    weak var view: (IMerchInfoModuleVC & ModuleVC)?
    private let router: PaymentRouting
    private var userService: UserService
    
    init(_ router: PaymentRouting,
         userService: UserService) {
        self.router = router
        self.userService = userService
        super.init()
    }
    
    func viewDidLoad() {
        
        configViews()
    }
    
    func profileButtonTapped() {
        
        guard let userInfo = userService.user?.userInfo else { return }
        router.openProfile(with: userInfo)
    }
    
    private func configViews() {
        
        guard let merchantInfo = userService.user?.merchantInfo else { return }
        
        view?.setupMerchInfo(shopName: merchantInfo.merchantName,
                             iconURL: merchantInfo.logoURL)
    }
}

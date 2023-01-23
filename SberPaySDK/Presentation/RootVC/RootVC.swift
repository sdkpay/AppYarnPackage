//
//  RootVC.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 15.11.2022.
//

import UIKit

final class RootVC: UIViewController {
    private let manager: SDKManager
    private let analytics: AnalyticsService
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SBLogger.log(.start)
        presentFirstVC()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SBLogger.log(.close)
    }

    init(manager: SDKManager, analytics: AnalyticsService) {
        self.manager = manager
        self.analytics = analytics
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func presentFirstVC() {
        let vc = AuthAssembly().createModule(manager: manager, analytics: analytics)
        let navVC = ContentNC(rootViewController: vc)
        present(navVC, animated: true, completion: nil)
    }
}

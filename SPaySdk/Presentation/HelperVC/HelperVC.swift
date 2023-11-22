//
//  HelperVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 19.11.2023.
//

import UIKit

private extension CGFloat {
    static let banksSpacing = 12.0
    static let bottomMargin = 45.0
    static let topMargin = 20.0
}

protocol IHelperVC {}

final class HelperVC: ContentVC, IHelperVC {
    
    private let presenter: AuthPresenting
    
    init(_ presenter: AuthPresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
        SBLogger.log(.didLoad(view: self))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SBLogger.log(.didAppear(view: self))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SBLogger.log(.didDissapear(view: self))
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    private func setupUI() {
        view.height(.minScreenSize, priority: .defaultLow)
    }
}

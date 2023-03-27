//
//  RootVC.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 15.11.2022.
//

import UIKit

final class RootVC: UIViewController {
    private let presenter: RootPresenting
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SBLogger.log(.didLoad(view: self))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SBLogger.log(.start)
        SBLogger.log(.didAppear(view: self))
        presenter.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SBLogger.log(.didDissapear(view: self))
        SBLogger.log(.close)
    }

    init(presenter: RootPresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

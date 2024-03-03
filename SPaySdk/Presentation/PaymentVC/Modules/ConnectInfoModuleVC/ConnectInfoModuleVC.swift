//
//  ConnectInfoModuleVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 02.03.2024.
//

import UIKit

private extension CGFloat {
    
    static let sideOffSet: CGFloat = 32.0
}

protocol IConnectInfoModuleVC {
    
    func setInfoText(_ text: String)
}

final class ConnectInfoModuleVC: ModuleVC, IConnectInfoModuleVC {
    
    private var presenter: ConnectInfoModulePresenting
    
    private(set) lazy var infoTextLabel: UILabel = {
        let view = UILabel()
        view.font = .header
        view.numberOfLines = 0
        view.textColor = .textPrimory
        return view
    }()
    
    init(_ presenter: ConnectInfoModulePresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        setupUI()
    }
    
    func setInfoText(_ text: String) {
        
        infoTextLabel.text = text
    }

    private func setupUI() {
        
        infoTextLabel
            .add(toSuperview: view)
            .touchEdge(.top, toSuperviewEdge: .top)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: .sideOffSet)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .sideOffSet)
            .touchEdge(.bottom, toSuperviewEdge: .bottom, withInset: .sideOffSet)
    }
}

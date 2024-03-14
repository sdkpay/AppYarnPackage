//
//  MerchInfoModuleVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 02.03.2024.
//

import UIKit

private extension CGFloat {
    
    static let sideOffSet: CGFloat = 32.0
    static let topOffSet: CGFloat = 36.0
    static let imageWidth: CGFloat = 52.0
    static let profileWidth: CGFloat = 36.0
}

protocol IMerchInfoModuleVC { 
    
    func setupMerchInfo(shopName: String, iconURL: String?)
}

final class MerchInfoModuleVC: ModuleVC, IMerchInfoModuleVC {
    
    private(set) lazy var shopLabel: UILabel = {
        let view = UILabel()
        view.font = .medium2
        view.height(view.requiredHeight)
        view.textColor = .textSecondary
        return view
    }()
    
    private(set) lazy var infoTextLabel: UILabel = {
        let view = UILabel()
        view.font = .header
        view.numberOfLines = 0
        view.height(view.requiredHeight)
        view.textColor = .textPrimory
        return view
    }()
    
    private(set) lazy var logoImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.layer.borderColor = Asset.Palette.grayDisabled.color.cgColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 16.0
        return view
    }()
    
    private(set) lazy var profileButton: ActionButton = {
        let view = ActionButton()
        view.addAction {
            self.presenter.profileButtonTapped()
        }
        view.setImage(Asset.Image.user.image, for: .normal)
        return view
    }()
    
    private var presenter: MerchInfoModulePresenting
    
    init(_ presenter: MerchInfoModulePresenting) {
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
    }
    
    func setupMerchInfo(shopName: String, iconURL: String?) {
        
        shopLabel.text = shopName
        logoImageView.downloadImage(from: iconURL, placeholder: .Payment.cart)
    }

    private func setupUI() {
        
        logoImageView.add(toSuperview: view)
        
        logoImageView
            .touchEdge(.left, toSuperviewEdge: .left, withInset: .sideOffSet)
            .touchEdge(.top, toSuperviewEdge: .top, withInset: .topOffSet)
            .size(.init(width: .imageWidth, height: .imageWidth))
        
        shopLabel
            .add(toSuperview: view)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: .sideOffSet)
            .touchEdge(.right, toSuperviewEdge: .right)
            .touchEdge(.top, toEdge: .bottom, ofView: logoImageView, withInset: .margin)
            .touchEdge(.bottom, toEdge: .bottom, ofView: view)
        
        profileButton
            .add(toSuperview: view)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .sideOffSet)
            .touchEdge(.top, toSuperviewEdge: .top, withInset: .topOffSet)
            .size(.init(width: .profileWidth, height: .profileWidth))
    }
}

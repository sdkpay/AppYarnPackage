//
//  AuthVC.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 23.11.2022.
//

import UIKit

private extension CGFloat {
    static let logoWidth = 96.0
    static let logoHeight = 48.0
    static let heightMultiple = 0.65
}

protocol IAuthVC {}

final class AuthVC: ContentVC, IAuthVC {
    
    private let presenter: AuthPresenting
    
    private lazy var logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(base64: UserDefaults.images?.logoBlack ?? "")
        return imageView
    }()
    
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
        
        view.height(.equal, to: UIScreen.main.bounds.height * .heightMultiple)
        
        logoImage
            .add(toSuperview: view)
            .size(.equal, to: .init(width: .logoWidth, height: .logoHeight))
            .centerInSuperview()
    }
}

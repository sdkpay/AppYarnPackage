//
//  ChallengeVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 22.11.2023.
//

import UIKit

private extension CGFloat {
    static let logoWidth = 96.0
    static let logoHeight = 48.0
    static let heightMultiple = 0.65
}

protocol IChallengeVC {
    func configView(header: String?, subtitle: String?, info: String?, mainButton: String?, cancelButton: String?)
}

final class ChallengeVC: ContentVC, IChallengeVC {

    private let presenter: ChallengePresenting
    
    private lazy var logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(base64: UserDefaults.images?.logoBlack ?? "")
        return imageView
    }()
    
    init(_ presenter: ChallengePresenting) {
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
    
    func configView(header: String?, subtitle: String?, info: String?, mainButton: String?, cancelButton: String?) {
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

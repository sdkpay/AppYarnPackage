//
//  LogoutVC.swift
//  SPaySdk
//
//  Created by Арсений on 17.08.2023.
//

import UIKit

protocol ILogoutVC {
}

final class LogoutVC: ContentVC, ILogoutVC {

    private let presenter: LogoutPresenting
    
    private(set) lazy var nextButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .full)
        let string = Strings.Button.logout
        view.setTitle(string, for: .normal)
        view.addAction {
            self.presenter.logout()
        }
        return view
    }()
    
    private(set) lazy var backButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .cancel)
        let string = Strings.Button.Logout.back
        view.setTitle(string, for: .normal)
        view.addAction {
            self.presenter.back()
        }
        return view
    }()
    
    init(_ presenter: LogoutPresenting, with userInfo: UserInfo) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        self.profileView.config(with: userInfo)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        topBarIsHidden = false
    }
    
    private func setupView() {
//        view.height(.minScreenSize, priority: .defaultLow)
        
        nextButton
            .add(toSuperview: view)
            .height(.defaultButtonHeight)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Button.Next.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.Button.Next.right)
            .touchEdge(.top, toEdge: .bottom, ofView: logoImage, withInset: Cost.Button.Next.top)
        
        backButton
            .add(toSuperview: view)
            .touchEdge(.bottom, toSuperviewEdge: .bottom, withInset: Cost.Button.Back.bottom)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Button.Back.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.Button.Back.right)
            .touchEdge(.top, toEdge: .bottom, ofView: nextButton, withInset: Cost.Button.Back.top)
            .height(.defaultButtonHeight)
    }
}

extension LogoutVC {
    enum Cost {
        static let sideOffSet: CGFloat = 16.0
        static let height = 56.0
        
        enum Button {
            static let height = Cost.height

            enum Next {
                static let bottom: CGFloat = 10.0
                static let right: CGFloat = Cost.sideOffSet
                static let left: CGFloat = Cost.sideOffSet
                static let top: CGFloat = 22
            }
            
            enum Back {
                static let bottom: CGFloat = 44.0
                static let right: CGFloat = Cost.sideOffSet
                static let left: CGFloat = Cost.sideOffSet
                static let top: CGFloat = Cost.sideOffSet
            }
        }
    }
}

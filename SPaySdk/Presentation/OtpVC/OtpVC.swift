//
//  OtpVC.swift
//  SPaySdk
//
//  Created by Арсений on 02.08.2023.
//

import UIKit

protocol IOtpVC: AnyObject {
    func updateTimer(sec: Int)
    func updateMobilePhone(phoneNumber: String)
}

final class OtpVC: ContentVC, IOtpVC {
    private let presenter: OtpPresenting
    private var otpCode = ""
        
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .left
        label.text = "Отправили СМС с кодом-подтверждением \n оплаты на номер +7 905 •••-76-46 "
        return label
    }()
    
    private lazy var textField: DefaultTextField = {
        let textField = DefaultTextField()
        textField.config(maxLength: 6,
                         textEdited: nil,
                         textEndEdited: { text in
            self.otpCode = text
        })
        return textField
    }()
    
    private lazy var timeButton: UIButton = {
        let timeButton = UIButton()
        timeButton.isEnabled = true
        return timeButton
    }()
    
    private(set) lazy var nextButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .full)
//        view.setTitle(String(stringLiteral: Cost.Button.Pay.title), for: .normal)
        view.addAction {
            self.presenter.sendOTP(otpCode: self.otpCode)
        }
        return view
    }()
    
    private(set) lazy var backButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .cancel)
//        view.setTitle(String(stringLiteral: Cost.Button.Cancel.title), for: .normal)
        view.addAction {
        }
        return view
    }()

    func updateTimer(sec: Int) {
        if sec > 0 {
            timeButton.isEnabled = true
            timeButton.setTitle("Отправим повторно через \(sec) секунд", for: .normal)
            timeButton.tintColor = ColorAsset.Color.backgroundPrimary
        } else {
            timeButton.isEnabled = false
            timeButton.setTitle("Отправить повторно", for: .normal)
            timeButton.tintColor = ColorAsset.Color.backgroundSecondary
        }
    }
    
    func updateMobilePhone(phoneNumber: String) {
        titleLabel.text = "Отправили СМС с кодом-подтверждением \n оплаты на номер \(phoneNumber) "
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.becomeFirstResponder()
        presenter.viewDidLoad()
        setupUI()
    }
    
    init(_ presenter: OtpPresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        titleLabel
            .add(toSuperview: view)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Stack.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.Stack.right)
            .touchEdge(.top, toEdge: .bottom, ofView: logoImage, withInset: Cost.Stack.top)
        
        textField
            .add(toSuperview: view)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.TextField.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.TextField.right)
            .touchEdge(.top, toEdge: .bottom, ofView: titleLabel, withInset: Cost.TextField.top)
        
        timeButton
            .add(toSuperview: view)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Button.Time.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.Button.Time.right)
            .touchEdge(.top, toEdge: .bottom, ofView: titleLabel, withInset: Cost.Button.Time.top)
        
        backButton
            .add(toSuperview: view)
            .touchEdge(.bottom, toSuperviewEdge: .bottom, withInset: Cost.Button.Back.bottom, usingRelation: .lessThanOrEqual)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Button.Back.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.Button.Back.right)
            .height(.defaultButtonHeight)
        
        nextButton
            .add(toSuperview: view)
            .height(.defaultButtonHeight)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Button.Next.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.Button.Next.right)
            .touchEdge(.bottom, toEdge: .top, ofView: backButton, withInset: Cost.Button.Next.bottom)
            .touchEdge(.top, toEdge: .bottom, ofView: timeButton, withInset: Cost.Button.Next.bottom)
    }
}

extension OtpVC {
    enum Cost {
        static let sideOffSet: CGFloat = 16.0
        static let height = 56.0

        enum Stack {
            static let bottom: CGFloat = 10.0
            static let right: CGFloat = Cost.sideOffSet
            static let left: CGFloat = Cost.sideOffSet
            static let top: CGFloat = 22.0
        }
        
        enum TextField {
            static let right: CGFloat = Cost.sideOffSet
            static let left: CGFloat = Cost.sideOffSet
            static let top: CGFloat = 20
        }
        
        enum Button {
            static let height = Cost.height

            enum Next {
                static let title = Strings.Pay.title
                static let bottom: CGFloat = 10.0
                static let right: CGFloat = Cost.sideOffSet
                static let left: CGFloat = Cost.sideOffSet
                static let top: CGFloat = 22
            }
            
            enum Back {
                static let title = Strings.Cancel.title
                static let bottom: CGFloat = 44.0
                static let right: CGFloat = Cost.sideOffSet
                static let left: CGFloat = Cost.sideOffSet
                static let top: CGFloat = Cost.sideOffSet
            }
            
            enum Time {
                static let right: CGFloat = Cost.sideOffSet
                static let left: CGFloat = Cost.sideOffSet
                static let top: CGFloat = 16
            }
        }
    }
}

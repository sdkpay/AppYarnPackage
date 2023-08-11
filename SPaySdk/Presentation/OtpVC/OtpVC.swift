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
    func showError()
    func hideKeyboard()
    func getKeyboardHeight(keyboardHeight: Int)
}

final class OtpVC: ContentVC, IOtpVC {
    private let presenter: OtpPresenting
    private var otpCode = ""
    private var maxLength = 6
    private var keyboardHeight = 330
        
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    private lazy var loader: UIActivityIndicatorView = {
        var loader = UIActivityIndicatorView(style: .whiteLarge)
        loader.layer.cornerRadius = 10
        loader.center = view.center
        return loader
    }()
    
    private lazy var textField: DefaultTextField = {
        let textField = DefaultTextField()
        textField.config(keyboardType: .numberPad,
                         maxLength: maxLength,
                         textEndEdited: {
            self.nextButton.isEnabled = $0.count == self.maxLength
            guard $0.count == self.maxLength else { return }
            self.otpCode = $0
        })
        return textField
    }()
    
    private lazy var timeButton: UIButton = {
        let timeButton = UIButton()
        timeButton.setTitleColor(.textSecondary, for: .normal)
        timeButton.isEnabled = true
        timeButton.titleLabel?.font = .medium2
        timeButton.titleLabel?.textAlignment = .left
        return timeButton
    }()
    
    private(set) lazy var nextButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .full)
        view.isEnabled = false
        let string = Strings.Next.Button.title
        view.setTitle(String(stringLiteral: "Продолжить"), for: .normal)
        view.addAction {
            self.presenter.sendOTP(otpCode: self.otpCode)
        }
        return view
    }()
    
    private(set) lazy var backButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .cancel)
        let string = Strings.Back.Button.title
        view.setTitle(String(stringLiteral: string), for: .normal)
        view.addAction {
            self.presenter.back()
        }
        return view
    }()
    
    func getKeyboardHeight(keyboardHeight: Int) {
        self.keyboardHeight = keyboardHeight
    }

    func updateTimer(sec: Int) {
        if sec > 0 {
            timeButton.isEnabled = true
            let string = Strings.Time.Button.Repeat.isNotActive(sec)
            timeButton.setTitle(string, for: .normal)
            timeButton.setTitleColor(.textSecondary, for: .normal)
        } else {
            timeButton.isEnabled = false
            let string = Strings.Time.Button.Repeat.isActive
            timeButton.setTitle(string, for: .normal)
            timeButton.setTitleColor(.main, for: .normal)
        }
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    func updateMobilePhone(phoneNumber: String) {
        titleLabel.text = Strings.TitleLabel.Message.title(phoneNumber)
    }
    
    func showError() {
        textField.addDescriptionLabel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        textField.becomeFirst()
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
            .touchEdge(.top, toEdge: .bottom, ofView: textField, withInset: Cost.Button.Time.top)
               
        nextButton
            .add(toSuperview: view)
            .height(.defaultButtonHeight)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Button.Next.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.Button.Next.right)
            .touchEdge(.top, toEdge: .bottom, ofView: timeButton, withInset: Cost.Button.Next.bottom)
        
        backButton
            .add(toSuperview: view)
            .touchEdge(.bottom, toSuperviewEdge: .bottom, withInset: CGFloat(keyboardHeight))
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Button.Back.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.Button.Back.right)
            .touchEdge(.top, toEdge: .bottom, ofView: nextButton, withInset: Cost.Button.Back.top)
            .height(.defaultButtonHeight)
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
                static let top: CGFloat = 12
            }
        }
    }
}

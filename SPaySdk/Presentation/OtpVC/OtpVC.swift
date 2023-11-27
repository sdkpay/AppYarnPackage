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
    func showError(with text: String)
    func hideKeyboard() async
    func setKeyboardHeight(height: CGFloat)
}

final class LoadableUIView: UIView, Loadable {}

final class OtpVC: ContentVC, IOtpVC {
    private let presenter: OtpPresenting
    private var otpCode = ""
    private var maxLength = 5
    private var keyboardHeight: CGFloat = 330
    
    private lazy var backView = LoadableUIView()
        
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .medium5
        label.textColor = .mainBlack
        return label
    }()
    
    private lazy var otpTextField: SmsCodeView = {
        let textField = SmsCodeView()
        textField.fullCodeDidEnter = {
            self.nextButton.isEnabled = $0.count == self.maxLength
            guard $0.count == self.maxLength else { return }
            self.otpCode = $0
        }
        
        return textField
    }()
    
    private lazy var timeButton: ActionButton = {
        let timeButton = ActionButton()
        timeButton.setTitleColor(.textSecondary, for: .normal)
        timeButton.isEnabled = true
        timeButton.titleLabel?.font = .medium4
        timeButton.titleLabel?.textAlignment = .center
        timeButton.addAction({
            self.nextButton.isEnabled = false
            self.presenter.createOTP()
        })
        return timeButton
    }()
    
    private(set) lazy var nextButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .full)
        view.isEnabled = false
        view.setTitle(Strings.Next.Button.title, for: .normal)
        view.addAction {
            self.presenter.sendOTP(otpCode: self.otpCode)
        }
        return view
    }()
    
    private(set) lazy var backButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .cancel)
        view.setTitle(Strings.Cancel.title, for: .normal)
        view.addAction {
            self.presenter.back()
        }
        return view
    }()
    
    func setKeyboardHeight(height: CGFloat) {
        self.keyboardHeight = height
    }
    
    func updateTimer(sec: Int) {
        if sec > 0 {
            timeButton.isEnabled = false
            let string = Strings.Time.Button.Repeat.isNotActive(sec)
            timeButton.setTitle(string, for: .normal)
            timeButton.setTitleColor(.textSecondary, for: .normal)
        } else {
            timeButton.isEnabled = true
            let string = Strings.Time.Button.Repeat.isActive
            timeButton.setTitle(string, for: .normal)
            timeButton.setTitleColor(.main, for: .normal)
        }
    }

    @MainActor
    func hideKeyboard() async {
        view.endEditing(true)
    }
    
    func updateMobilePhone(phoneNumber: String) {
        titleLabel.text = Strings.TitleLabel.Message.title(phoneNumber)
    }
    
    func showError(with text: String) {
        timeButton.setTitle(text, for: .normal)
        timeButton.isEnabled = true
        timeButton.setTitleColor(.red, for: .normal)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        setupUI()
        backView.isUserInteractionEnabled = true
        
        self.otpTextField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.viewDidDisappear()
    }
    
    init(_ presenter: OtpPresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @MainActor
    override func showLoading(with text: String? = nil, animate: Bool = true) {
        backView.startLoading(with: text)
        nextButton.isHidden = true
        backButton.isHidden = true
        view.endEditing(true)
    }
    
    @MainActor
    override func hideLoading(animate: Bool = true) {
        backView.stopLoading()
        nextButton.isHidden = false
        backButton.isHidden = false
    }
    
    private func setupUI() {
        view.height(.vcMaxHeight, priority: .defaultLow)
        
        backView
            .add(toSuperview: view)
            .touchEdge(.left, toSuperviewEdge: .left)
            .touchEdge(.right, toSuperviewEdge: .right)
            .touchEdge(.top, toSuperviewEdge: .top)
            .touchEdge(.bottom, toSuperviewEdge: .bottom)

        titleLabel
            .add(toSuperview: backView)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Stack.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.Stack.right)
            .touchEdge(.top, toEdge: .top, ofView: backView, withInset: Cost.Stack.top)
        
        otpTextField
            .add(toSuperview: backView)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.TextField.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.TextField.right)
            .touchEdge(.top, toEdge: .bottom, ofView: titleLabel, withInset: Cost.TextField.top)
            .height(Cost.TextField.height)
        
        timeButton
            .add(toSuperview: backView)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Button.Time.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.Button.Time.left)
            .touchEdge(.top, toEdge: .bottom, ofView: otpTextField, withInset: Cost.Button.Time.top)
               
        nextButton
            .add(toSuperview: view)
            .height(.defaultButtonHeight)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Button.Next.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.Button.Next.right)
            .touchEdge(.top, toEdge: .bottom, ofView: timeButton, withInset: Cost.Button.Next.bottom)
        
        backButton
            .add(toSuperview: view)
            .height(.defaultButtonHeight)
            .touchEdge(.bottom, toEdge: .bottom, ofView: view, withInset: CGFloat(keyboardHeight))
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Button.Back.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.Button.Back.right)
            .touchEdge(.top, toEdge: .bottom, ofView: nextButton, withInset: Cost.Button.Back.top)
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
            static let top: CGFloat = 60.0
            static let height: CGFloat = 40
        }
        
        enum TextField {
            static let right: CGFloat = Cost.sideOffSet
            static let left: CGFloat = Cost.sideOffSet
            static let top: CGFloat = 16
            static let height: CGFloat = 72
        }
        
        enum Button {
            static let height = Cost.height

            enum Next {
                static let title = Strings.Pay.title
                static let bottom: CGFloat = 40.0
                static let right: CGFloat = Cost.sideOffSet
                static let left: CGFloat = Cost.sideOffSet
                static let top: CGFloat = 22
            }
            
            enum Back {
                static let title = Strings.Cancel.title
                static let bottom: CGFloat = 0
                static let right: CGFloat = Cost.sideOffSet
                static let left: CGFloat = Cost.sideOffSet
                static let top: CGFloat = 8
            }
            
            enum Time {
                static let right: CGFloat = Cost.sideOffSet
                static let left: CGFloat = Cost.sideOffSet
                static let top: CGFloat = 16
            }
        }
    }
}

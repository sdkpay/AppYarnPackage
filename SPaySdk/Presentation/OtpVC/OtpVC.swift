//
//  OtpVC.swift
//  SPaySdk
//
//  Created by Арсений on 02.08.2023.
//

import UIKit

protocol IOtpVC: AnyObject {
    func updateMobilePhone(phoneNumber: String)
    func setOtpDescription(_ text: String)
    func setViewState(_ state: OtpViewState)
    func setOtpError(_ text: String?)
    func hideKeyboard() async
}

final class LoadableUIView: UIView, Loadable {}

enum OtpViewState {
    case ready
    case waiting
    case error
}

final class OtpVC: ContentVC, IOtpVC {
    
    private let presenter: OtpPresenting
    private var otpCode = ""
    private var kbSize = CGSize(width: UIScreen.main.bounds.width,
                                height: 300)
    
    private lazy var contentView = LoadableUIView()
    
    private lazy var keyboardView = UIView()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .medium5
        label.textColor = .textPrimory
        return label
    }()
    
    private lazy var otpTextField: SmsCodeView = {
        let textField = SmsCodeView()
        textField.fullCodeDidEnter = {
            self.otpCode = $0
        }
        textField.textFieldDidChangeAction = {
            self.presenter.otpFieldChanged()
        }
        return textField
    }()
    
    private lazy var otpErrorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .medium4
        label.textColor = Asset.red.color
        label.isHidden = true
        return label
    }()
    
    private lazy var otpDescriptionButton: ActionButton = {
        let timeButton = ActionButton()
        timeButton.setTitleColor(.textSecondary, for: .normal)
        timeButton.isEnabled = true
        timeButton.titleLabel?.font = .medium4
        timeButton.titleLabel?.textAlignment = .center
        timeButton.sizeToFit()
        timeButton.addAction({
            self.presenter.createOTP()
        })
        return timeButton
    }()
    
    private lazy var otpActionStack: UIStackView = {
        let view = UIStackView()
        view.distribution = .fill
        view.alignment = .center
        view.axis = .vertical
        view.spacing = 10
        view.addArrangedSubview(otpErrorLabel)
        view.addArrangedSubview(otpDescriptionButton)
        return view
    }()
    
    private(set) lazy var nextButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .full)
        view.setTitle(Strings.Next.Button.title, for: .normal)
        view.addAction {
            self.presenter.sendOTP(otpCode: self.otpCode)
        }
        return view
    }()
    
    private(set) lazy var backButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .clear)
        view.setTitle(Strings.Cancel.title, for: .normal)
        view.addAction {
            self.presenter.back()
        }
        return view
    }()
    
    func setViewState(_ state: OtpViewState) {
        
        switch state {
        case .ready:

            otpTextField.setState(.full)
            otpDescriptionButton.isEnabled = true
            otpDescriptionButton.setTitleColor(.main, for: .normal)
        case .waiting:
            
            otpDescriptionButton.isEnabled = false
            otpDescriptionButton.setTitleColor(.textSecondary, for: .normal)
        case .error:
            
            otpTextField.setState(.error)
        }
    }
    
    func setOtpDescription(_ text: String) {
        
        otpDescriptionButton.setTitle(text, for: .normal)
    }
    
    func setOtpError(_ text: String?) {
        
        self.otpErrorLabel.text = text
        
        UIView.animate(withDuration: 0.25,
                       delay: .zero,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 1) {
            
            self.otpErrorLabel.isHidden = text == nil
            self.otpActionStack.layoutIfNeeded()
        }
    }

    @MainActor
    func hideKeyboard() async {
        
        view.endEditing(true)
    }
    
    func updateMobilePhone(phoneNumber: String) {
        
        titleLabel.text = Strings.TitleLabel.Message.title(phoneNumber)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addKeyboardObserver()
        otpTextField.becomeFirstResponder()
        presenter.viewDidLoad()
        setupUI()
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
    
    deinit {
        removeKeyboardObserver()
    }
    
    @MainActor
    override func showLoading(with text: String? = nil, animate: Bool = true) {
        contentView.startLoading(with: text)
    }
    
    @MainActor
    override func hideLoading(animate: Bool = true) {
        contentView.stopLoading()
    }
    
    private func addKeyboardObserver() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func removeKeyboardObserver() {
        
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillChangeFrameNotification,
                                                  object: nil)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
    
    @objc 
    private
    func keyboardWillShow(_ notification: Notification?) {
        
        if let info = notification?.userInfo {
            
            let frameEndUserInfoKey = UIResponder.keyboardFrameEndUserInfoKey
            
            if let kbFrame = info[frameEndUserInfoKey] as? CGRect {
                
                let screenSize = UIScreen.main.bounds
                let intersectRect = kbFrame.intersection(screenSize)
                
                if intersectRect.isNull {
                    kbSize = CGSize(width: screenSize.size.width, height: 0)
                } else {
                    kbSize = intersectRect.size
                }
            }
        }
        updateKeyboardViewSize()
    }
    
    @objc
    private
    func keyboardWillHide(_ notification: Notification?) {
        
        let screenSize = UIScreen.main.bounds
        kbSize = CGSize(width: screenSize.size.width, height: 0)
        updateKeyboardViewSize()
    }
    
    private func updateKeyboardViewSize() {

        UIView.animate(withDuration: 0.25) {
            self.keyboardView.layoutIfNeeded()
        }
    }
    
    private func setupUI() {
        
        contentView
            .add(toSuperview: view)
            .touchEdge(.left, toSuperviewEdge: .left)
            .touchEdge(.right, toSuperviewEdge: .right)
            .touchEdge(.top, toSuperviewEdge: .top)

        titleLabel
            .add(toSuperview: contentView)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Stack.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.Stack.right)
            .touchEdge(.top, toEdge: .top, ofView: contentView, withInset: Cost.Stack.top, priority: .defaultHigh)
        
        otpTextField
            .add(toSuperview: contentView)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.TextField.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.TextField.right)
            .touchEdge(.top, toEdge: .bottom, ofView: titleLabel, withInset: Cost.TextField.top)
            .height(Cost.TextField.height)
        
        otpActionStack
            .add(toSuperview: contentView)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Button.Time.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.Button.Time.left)
            .touchEdge(.top, toEdge: .bottom, ofView: otpTextField, withInset: Cost.Button.Time.top)
            .height(Cost.height)
               
        nextButton
            .add(toSuperview: contentView)
            .height(.defaultButtonHeight)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Button.Next.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.Button.Next.right)
            .touchEdge(.top, toEdge: .bottom, ofView: otpActionStack, withInset: Cost.Button.Next.bottom)
        
        backButton
            .add(toSuperview: contentView)
            .height(.defaultButtonHeight)
            .touchEdge(.bottom, toEdge: .bottom, ofView: contentView, withInset: Cost.Button.Back.bottom)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Button.Back.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.Button.Back.right)
            .touchEdge(.top, toEdge: .bottom, ofView: nextButton, withInset: Cost.Button.Back.top)
        
        keyboardView
            .add(toSuperview: view)
            .touchEdge(.left, toSuperviewEdge: .left)
            .touchEdge(.right, toSuperviewEdge: .right)
            .touchEdge(.top, toEdge: .bottom, ofView: contentView)
            .touchEdge(.bottom, toSuperviewEdge: .bottom, priority: .defaultLow)
            .size(kbSize)
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

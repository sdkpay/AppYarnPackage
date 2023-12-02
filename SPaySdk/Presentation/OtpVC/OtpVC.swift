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
}

final class LoadableUIView: UIView, Loadable {}

final class OtpVC: ContentVC, IOtpVC {
    private let presenter: OtpPresenting
    private var otpCode = ""
    private var maxLength = 5
    private var kbSize = CGSize(width: UIScreen.main.bounds.width,
                                height: 300)
    
    private lazy var contentView = LoadableUIView()
    
    private lazy var keyboardView = UIView()
    
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
        let view = DefaultButton(buttonAppearance: .clear)
        view.setTitle(Strings.Cancel.title, for: .normal)
        view.addAction {
            self.presenter.back()
        }
        return view
    }()
    
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
        nextButton.isHidden = true
        backButton.isHidden = true
        view.endEditing(true)
    }
    
    @MainActor
    override func hideLoading(animate: Bool = true) {
        contentView.stopLoading()
        nextButton.isHidden = false
        backButton.isHidden = false
    }
    
    private func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
    }
    
    private func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
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
            .touchEdge(.top, toEdge: .top, ofView: contentView, withInset: Cost.Stack.top)
            .height(titleLabel.requiredHeight)
        
        otpTextField
            .add(toSuperview: contentView)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.TextField.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.TextField.right)
            .touchEdge(.top, toEdge: .bottom, ofView: titleLabel, withInset: Cost.TextField.top)
            .height(Cost.TextField.height)
        
        timeButton
            .add(toSuperview: contentView)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Button.Time.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.Button.Time.left)
            .touchEdge(.top, toEdge: .bottom, ofView: otpTextField, withInset: Cost.Button.Time.top)
            .height(.defaultButtonHeight)
               
        nextButton
            .add(toSuperview: contentView)
            .height(.defaultButtonHeight)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.Button.Next.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.Button.Next.right)
            .touchEdge(.top, toEdge: .bottom, ofView: timeButton, withInset: Cost.Button.Next.bottom)
        
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
            .touchEdge(.bottom, toSuperviewEdge: .bottom)
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

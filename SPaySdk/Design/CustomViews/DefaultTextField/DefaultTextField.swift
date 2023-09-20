import UIKit

enum TextFieldState {
    case alert
    case selected
    case empty
    
    var color: UIColor {
        switch self {
        case .alert:
            return .systemRed.withAlphaComponent(0.7)
        case .selected, .empty:
            return ColorAsset.Color.backgroundSecondary
        }
    }
}

private extension CGFloat {
    static let backMargin = 4.0
    static let textMargin = 20.0
    static let alertMargin = 20.0
    static let height = 64.0
    static let buttonHeight = 45.0
}

final class DefaultTextField: UIView {
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.layer.borderColor = ColorAsset.Color.backgroundSecondary.cgColor
        view.layer.borderWidth = 1.5
        view.layer.cornerRadius = 7
        return view
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 13, weight: .light)
        view.numberOfLines = 1
        view.textAlignment = .left
        view.alpha = 1
        view.textColor = TextFieldState.alert.color
        return view
    }()
    
    private lazy var mainStack: UIStackView = {
        let view = UIStackView()
        view.addArrangedSubview(backgroundView)
        view.axis = .vertical
        view.spacing = 4
        return view
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .light)
        label.textColor = .gray
        label.text = Strings.Otp.Placeholder.title
        return label
    }()
    
    private lazy var textFiledStakView: UIStackView = {
        let stackView = UIStackView()
        stackView.addArrangedSubview(textField)
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var textField: InsertTextField = {
        let view = InsertTextField()
        view.borderStyle = .none
        view.delegate = self
        view.textAlignment = .left
        view.clearButtonMode = .never
        view.addTarget(self, action: #selector(editingBegin), for: .editingChanged)
        view.addTarget(self, action: #selector(editingEnd), for: .editingDidEnd)
        view.addTarget(self, action: #selector(valueChanged), for: .allEvents)
        return view
    }()
    
    private lazy var alertButton: ActionButton = {
        let view = ActionButton()
        if #available(iOS 13.0, *) {
            view.setImage(UIImage(systemName: "exclamationmark.circle.fill"),
                          for: .normal)
        }
        view.tintColor = TextFieldState.alert.color
        view.alpha = 0
        return view
    }()

    private var textEndEdited: ((String) -> Void)?
    private var maxLength: Int?
    
    func config(keyboardType: UIKeyboardType,
                maxLength: Int?,
                textEndEdited: @escaping (String) -> Void,
                buttonTapped: (() -> Void)? = nil) {
        textField.placeholder = Strings.Otp.Placeholder.title
        self.maxLength = maxLength
        if maxLength != nil {
            valueChanged()
        }
        textField.keyboardType = keyboardType
        textField.textContentType = .oneTimeCode
        self.textEndEdited = textEndEdited
        setupUI()
    }
    
    func becomeFirst() {
        textField.becomeFirstResponder()
    }
    
    func setState(_ state: TextFieldState, animate: Bool = true) {
        UIView.animate(withDuration: animate ? 0.25 : 0.0,
                       delay: .zero,
                       options: .transitionCrossDissolve,
                       animations: {
            self.backgroundView.layer.borderColor = state.color.cgColor
        }, completion: nil)
    }
    
    @objc
    private func editingBegin() {
        textFiledStakView.removeArrangedSubview(textField)
        textFiledStakView.addArrangedSubview(placeholderLabel)
        textFiledStakView.addArrangedSubview(textField)
        setState(.selected)
    }
    
    @objc
    private func editingEnd() {
        setState(.empty)
        textEndEdited?(textField.text ?? "")
    }
    
    @objc
    private func valueChanged() {
        descriptionLabel.alpha = 0
        textEndEdited?(textField.text ?? "")
    }
    
    func addDescriptionLabel(with text: String) {
        descriptionLabel.text = text
        mainStack.removeArrangedSubview(backgroundView)
        mainStack.addArrangedSubview(backgroundView)
        mainStack.addArrangedSubview(descriptionLabel)
        descriptionLabel.alpha = 1
        textField.text = nil
        textField.placeholder = nil
        setState(.alert)
    }
    
    func addDefaultLabel() {
        mainStack.removeArrangedSubview(backgroundView)
        mainStack.addArrangedSubview(backgroundView)
        mainStack.removeArrangedSubview(descriptionLabel)
        descriptionLabel.alpha = 0
        setState(.selected)
    }
    
    private func setupUI() {
        mainStack
            .add(toSuperview: self)
            .touchEdge(.top, toEdge: .top, ofView: self)
            .touchEdge(.left, toEdge: .left, ofView: self)
            .touchEdge(.right, toEdge: .right, ofView: self)
            .touchEdge(.bottom, toEdge: .bottom, ofView: self)
        
        backgroundView
            .add(toSuperview: mainStack)
            .touchEdge(.top, toEdge: .top, ofView: self, withInset: .backMargin)
            .touchEdge(.left, toEdge: .left, ofView: self, withInset: .backMargin)
            .touchEdge(.right, toEdge: .right, ofView: self, withInset: .backMargin)
            .height(.height)
    
        textFiledStakView
            .add(toSuperview: backgroundView)
            .touchEdge(.top, toEdge: .top, ofView: backgroundView, withInset: 8)
            .touchEdge(.left, toEdge: .left, ofView: backgroundView, withInset: 8)
            .touchEdge(.right, toEdge: .right, ofView: backgroundView, withInset: .backMargin)
            .touchEdge(.bottom, toEdge: .bottom, ofView: backgroundView, withInset: 8)
    }
}

final class InsertTextField: UITextField {
    private var padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}

extension DefaultTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= maxLength ?? 0
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= maxLength ?? 0
    }
}

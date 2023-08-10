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
            return ColorAsset.Color.gray
        }
    }
}

private extension CGFloat {
    static let backMargin = 4.0
    static let alertMargin = 20.0
    static let height = 54.0
    static let buttonHeight = 45.0
}

final class DefaultTextField: UIView {
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.layer.borderColor = ColorAsset.Color.gray.cgColor
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
        view.text = "fdsfdsfsfs"
        return view
    }()
    
    private lazy var mainStack: UIStackView = {
        let view = UIStackView()
        view.addArrangedSubview(backgroundView)
        view.axis = .vertical
        return view
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .light)
        label.textColor = .gray
        label.text = "Код-подтверждение"
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
        view.textAlignment = .left
        view.clearButtonMode = .whileEditing
        view.addTarget(self, action: #selector(editingBegin), for: .editingChanged)
        view.addTarget(self, action: #selector(editingEnd), for: .editingDidEnd)
        view.addTarget(self, action: #selector(valueChanged), for: .allEvents)
        view.becomeFirstResponder()
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

    private var textEdited: ((String) -> Void)?
    private var textEndEdited: ((String) -> Void)?
    private var maxLength: Int?
    
    func config(text: String?,
                keyboardType: UIKeyboardType,
                placeholder: String?,
                description: String?,
                maxLength: Int?,
                textEdited: @escaping (String) -> Void,
                textEndEdited: @escaping (String) -> Void,
                buttonTapped: (() -> Void)? = nil) {
        textField.text = text
        textField.placeholder = placeholder
        descriptionLabel.text = description
        self.maxLength = maxLength
        if maxLength != nil {
            valueChanged()
        }
        textField.keyboardType = keyboardType
        textField.textContentType = .oneTimeCode
        self.textEdited = textEdited
        self.textEndEdited = textEndEdited
        setupUI()
    }
    
    func setState(_ state: TextFieldState, animate: Bool = true) {
        UIView.animate(withDuration: animate ? 0.25 : 0.0,
                       delay: .zero,
                       options: .transitionCrossDissolve,
                       animations: {
            self.backgroundView.layer.borderColor = state.color.cgColor
            self.descriptionLabel.textColor = state.color
            self.descriptionLabel.alpha = state != .alert ? 0 : 1
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
        textEdited?(textField.text ?? "")
        guard let maxLength else { return }
        let currentLength = (maxLength - (textField.text?.count ?? 0))
        textEdited?(textField.text ?? "")
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
        
//        descriptionLabel
//            .add(toSuperview: self)
//            .touchEdge(.top, toEdge: .bottom, ofView: backgroundView, withInset: .backMargin)
//            .touchEdge(.left, toEdge: .left, ofView: backgroundView, withInset: .backMargin)
//            .touchEdge(.right, toEdge: .left, ofView: backgroundView, withInset: .margin)
//            .touchEdge(.bottom, toEdge: .bottom, ofView: self, withInset: .backMargin)
    }
}

final class InsertTextField: UITextField {
    private var padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .buttonHeight)
    
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

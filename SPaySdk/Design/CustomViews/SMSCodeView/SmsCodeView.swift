//
//  SmsCodeView.swift
//  O2G
//
//  Created by Александр Ипатов on 30.08.2021.
//

import UIKit

private enum FieldStatus {
    case empty, full, error
}

final class SmsCodeView: UITextField {
    // MARK: - Properties
    private let numberOfCharacters: Int = 5

    var fullCodeDidEnter: ((String) -> Void)?

    private var labels = [UILabel]()

    private lazy var tapRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        recognizer.addTarget(self, action: #selector(becomeFirstResponder))
        return recognizer
    }()
    // MARK: - UI components
    private lazy var stackForLabels: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = Consts.stackSpasing
        return stackView
    }()

    @objc
    private func textDidChange() {
        guard let text = self.text, text.count <= numberOfCharacters else { return }
        for i in 0 ..< numberOfCharacters {
            let currentLabel = labels[i]
            if i < text.count {
                let index = text.index(text.startIndex, offsetBy: i)
                setLabelStatus(label: currentLabel,
                               fieldStatus: .full,
                               text: String(text[index]))
            } else {
                setLabelStatus(label: currentLabel,
                               fieldStatus: i == 0 ? .empty : .full,
                               text: "•")
            }
        }
        if text.count == numberOfCharacters {
            fullCodeDidEnter?(text)
        }
    }
    
    func errorState() {
        cleanAllFields()
        for label in labels {
            setLabelStatus(label: label, fieldStatus: .error, text: "•")
        }
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSmsCodeView()
        setupUI()
        addLabelsToStack()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureSmsCodeView() {
        tintColor = .clear
        textColor = .clear
        isUserInteractionEnabled = true
        addGestureRecognizer(tapRecognizer)
        keyboardType = .numberPad
        textContentType = .oneTimeCode
        addTarget(self,
                  action: #selector(textDidChange),
                  for: .editingChanged)
        delegate = self
        .height(Consts.heightOfView)
    }

    private func setupUI() {

        stackForLabels
            .add(toSuperview: self)
            .touchEdge(.top, toEdge: .top, ofView: self, withInset: Consts.topOfStack)
            .touchEdgesToSuperview(ofGroup: .horizontal)
            .touchEdge(.bottom, toEdge: .top, ofView: self, withInset: Consts.bottomOfStack)
            .height(Consts.heightOfStack)
    }
}
extension SmsCodeView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let charCount = textField.text?.count else { return false }
        return charCount < numberOfCharacters || string.isEmpty
    }
}
// MARK: - Labels methods
extension SmsCodeView {
    private func addLabelsToStack() {
        for _ in 1 ... numberOfCharacters {
            let label: UILabel = {
                let label = UILabel()
                label.textAlignment = .center
                label.text = "•"
                label.font = .header4
                label.textColor = .mainBlack
                label.isUserInteractionEnabled = true
                return label
            }()
            stackForLabels.addArrangedSubview(label)
            labels.append(label)
        }
    }

    private func setLabelStatus(label: UILabel,
                                fieldStatus: FieldStatus,
                                text: String) {
        label.text = text
        switch fieldStatus {
        case .empty:
            label.textColor = .textSecondary
        case .full:
            label.textColor = .mainBlack
        case .error:
            label.textColor = .red
        }
    }

    private func cleanAllFields() {
        self.text = ""
        for label in labels {
            setLabelStatus(label: label,
                           fieldStatus: .empty,
                           text: "•")
        }
    }
}

private extension SmsCodeView {
    enum Consts {
        static let stackSpasing: CGFloat = 8
        static let heightOfView: CGFloat = 30
        static let topOfStack: CGFloat = 8
        static let bottomOfStack: CGFloat = 2
        static let heightOfStack: CGFloat = 28
    }
}

//
//  SwitchCell.swift
//  SPaySdkExample
//
//  Created by Ипатов Александр Станиславович on 03.05.2023.
//

import UIKit

private extension CGFloat {
    static let topMargin = 15.0
    static let sideMargin = 20.0
}

final class SwitchCell: UITableViewCell {
    static var reuseID: String { "SwitchCell" }

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = .black
        return view
    }()
    
    private lazy var switchControl: UISwitch = {
        let view = UISwitch(frame: .zero)
        view.addTarget(self, action: #selector(switchControlChanged), for: .allEvents)
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fill
        view.axis = .horizontal
        view.spacing = 10
        view.addArrangedSubview(titleLabel)
        view.addArrangedSubview(switchControl)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var valueChanged: ((String) -> Void)?
    
    func config(with title: String,
                value: String,
                valueChanged: @escaping (String) -> Void) {
        titleLabel.text = title
        switchControl.isOn = value.bool ?? false
        self.valueChanged = valueChanged
        setupUI()
    }
    
    @objc
    private func switchControlChanged() {
        valueChanged?(String(switchControl.isOn))
    }
    
    func setupUI() {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        contentView.addSubview(stackView)
        backgroundColor = .white
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                           constant: .topMargin),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                               constant: .sideMargin),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                constant: -.sideMargin),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                              constant: -.topMargin)
        ])
    }
}

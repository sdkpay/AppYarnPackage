//
//  SwitchCell.swift
//  SPaySdkExample
//
//  Created by Ипатов Александр Станиславович on 25.05.2023.
//

import UIKit

private extension CGFloat {
    static let topMargin = 10.0
}

final class SwitchCell: UITableViewCell {    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = .gray
        view.font = .systemFont(ofSize: 13, weight: .medium)
        view.sizeToFit()
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
        view.alignment = .center
        view.axis = .horizontal
        view.spacing = 10
        view.addArrangedSubview(titleLabel)
        view.addArrangedSubview(switchControl)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var valueChanged: ((Bool) -> Void)?
    
    func config(with title: String,
                value: Bool,
                valueChanged: @escaping (Bool) -> Void) {
        titleLabel.text = title
        switchControl.isOn = value
        self.valueChanged = valueChanged
        setupUI()
    }
    
    @objc
    private func switchControlChanged() {
        valueChanged?(switchControl.isOn)
    }
    
    private func setupUI() {
        stackView
            .add(toSuperview: contentView)
            .touchEdge(SBEdge.top, toEdge: SBEdge.top, ofView: contentView)
            .touchEdge(SBEdge.left, toEdge: SBEdge.left, ofView: contentView, withInset: .sideMargin)
            .touchEdge(SBEdge.bottom, toEdge: SBEdge.bottom, ofView: contentView)
            .touchEdge(SBEdge.right, toEdge: SBEdge.right, ofView: contentView, withInset: 10.0)
    }
}

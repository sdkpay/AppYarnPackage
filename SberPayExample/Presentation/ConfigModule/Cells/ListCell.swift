//
//  ListCell.swift
//  SPaySdkExample
//
//  Created by Ипатов Александр Станиславович on 25.05.2023.
//

import UIKit
import SBLayout

private extension CGFloat {
    static let topMargin = 10.0
}

final class ListCell: UITableViewCell {
    static var reuseID: String { "ListCell" }

    private lazy var refreshButton: ActionButton = {
        let view = ActionButton()
        view.addAction {
            self.tapped?()
        }
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = .gray
        view.font = .systemFont(ofSize: 13, weight: .medium)
        view.sizeToFit()
        return view
    }()
    
    private lazy var valueLabel: UILabel = {
        let view = UILabel()
        view.textColor = .black
        view.textAlignment = .right
        view.font = .systemFont(ofSize: 14)
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fill
        view.alignment = .center
        view.axis = .horizontal
        view.spacing = 10
        view.addArrangedSubview(titleLabel)
        view.addArrangedSubview(valueLabel)
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var tapped: Action?
    private var items: [String]?
    
    func config(title: String,
                value: String,
                selectedItem: Action?) {
        titleLabel.text = title
        valueLabel.text = value
        tapped = selectedItem
        setupUI()
    }

    private func setupUI() {
        stackView
            .add(toSuperview: contentView)
            .touchEdge(SBEdge.top, toSuperviewEdge: SBEdge.top)
            .touchEdge(SBEdge.left, toEdge: SBEdge.left, ofView: contentView, withInset: .sideMargin)
            .touchEdge(SBEdge.bottom, toEdge: SBEdge.bottom, ofView: contentView)
            .touchEdge(SBEdge.right, toEdge: SBEdge.right, ofView: contentView, withInset: .sideMargin)
        
        refreshButton
            .add(toSuperview: stackView)
            .touchEdge(SBEdge.top, toEdge: SBEdge.top, ofView: contentView)
            .touchEdge(SBEdge.left, toEdge: SBEdge.left, ofView: contentView)
            .touchEdge(SBEdge.bottom, toEdge: SBEdge.bottom, ofView: contentView)
            .touchEdge(SBEdge.right, toEdge: SBEdge.right, ofView: contentView)
    }
}

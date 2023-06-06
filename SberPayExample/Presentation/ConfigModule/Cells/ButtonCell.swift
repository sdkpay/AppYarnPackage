//
//  ButtonCell.swift
//  SPaySdkExample
//
//  Created by Ипатов Александр Станиславович on 26.05.2023.
//

import UIKit
import SBLayout

private extension CGFloat {
    static let topMargin = 10.0
}

final class ButtonCell: UITableViewCell {
    static var reuseID: String { "ButtonCell" }

    private lazy var button: ActionButton = {
        let view = ActionButton()
        view.setTitleColor(.systemBlue, for: .normal)
        view.addAction {
            self.tapped?()
        }
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
    
    func config(title: String,
                selectedItem: Action?) {
        button.setTitle(title, for: .normal)
        tapped = selectedItem
        setupUI()
    }

    private func setupUI() {
        button
            .add(toSuperview: contentView)
            .touchEdge(SBEdge.top, toEdge: SBEdge.top, ofView: contentView)
            .touchEdge(SBEdge.left, toEdge: SBEdge.left, ofView: contentView)
            .touchEdge(SBEdge.bottom, toEdge: SBEdge.bottom, ofView: contentView)
            .touchEdge(SBEdge.right, toEdge: SBEdge.right, ofView: contentView)
    }
}

//
//  FinalCell.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 18.04.2023.
//

import UIKit

final class FinalCell: UITableViewCell {
    static var reuseId: String { "FinalCell" }

    private lazy var finalLabel: UILabel = {
        let view = UILabel()
        view.font = .bodi1
        view.textColor = .textPrimory
        view.text = .PayPart.final
        return view
    }()
    
    private lazy var finalCostLabel: UILabel = {
       let view = UILabel()
        view.font = .bodi1
        view.textColor = .textPrimory
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(with finalCost: String) {
        finalCostLabel.text = finalCost
    }
    
    private func setupUI() {
        contentView.addSubview(finalLabel)
        contentView.addSubview(finalCostLabel)
        
        finalLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            finalLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            finalLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        ])
        
        finalCostLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            finalCostLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            finalCostLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}


//
//  PartCell.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 18.04.2023.
//

import UIKit

private extension CGFloat {
    static let pointWidth = 20.0
    static let lineHeight = 22.0
    static let lineWidth = 2.0
    static let lineMargin = 2.0
}

final class PartCell: UITableViewCell {
    static var reuseId: String { "PartCell" }

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        return view
    }()
    
    private lazy var costLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .right
        return view
    }()
    
    private lazy var pointView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private lazy var lineView: UIView = {
        let view = UIView()
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(with model: PartCellModel) {
        titleLabel.text = model.title
        costLabel.text = model.cost
        lineView.isHidden = model.hideLine
        titleLabel.font = model.isSelected ? .bodi1 : .bodi2
        titleLabel.font = model.isSelected ? .bodi1 : .bodi2
        titleLabel.textColor = model.isSelected ? .textPrimory : .textSecondary
        costLabel.textColor = model.isSelected ? .textPrimory : .textSecondary
    }
    
    private func setupUI() {
        addSubview(pointView)
        pointView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pointView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pointView.topAnchor.constraint(equalTo: topAnchor),
            pointView.widthAnchor.constraint(equalToConstant: .pointWidth),
            pointView.heightAnchor.constraint(equalToConstant: .pointWidth)
        ])
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: pointView.trailingAnchor, constant: .margin),
            titleLabel.centerYAnchor.constraint(equalTo: pointView.centerYAnchor)
        ])
        
        addSubview(costLabel)
        costLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            costLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            costLabel.centerYAnchor.constraint(equalTo: pointView.centerYAnchor),
            costLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
        
        addSubview(lineView)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lineView.centerXAnchor.constraint(equalTo: pointView.centerXAnchor),
            lineView.topAnchor.constraint(equalTo: pointView.bottomAnchor, constant: .lineMargin),
            lineView.widthAnchor.constraint(equalToConstant: .lineWidth),
            lineView.heightAnchor.constraint(equalToConstant: .lineHeight)
        ])
    }
}

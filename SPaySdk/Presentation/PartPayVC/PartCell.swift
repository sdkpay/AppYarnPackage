//
//  PartCell.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 18.04.2023.
//

import UIKit

private extension CGFloat {
    static let pointBackgroundWidth = 20.0
    static let pointWidth = 12.0
    static let lineHeight = 22.0
    static let lineWidth = 2.0
    static let lineMargin = 2.0
}

final class PartCell: UITableViewCell {
    private lazy var titleLabel = UILabel()

    private lazy var costLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .right
        return view
    }()
    
    private lazy var pointView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = .pointWidth / 2
        return view
    }()
    
    private lazy var backgroundPointView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = .pointBackgroundWidth / 2
        return view
    }()
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .textSecondary.withAlphaComponent(0.1)
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
        lineView.isHidden = model.hideLine
        titleLabel.font = model.isSelected ? .medium1 : .medium2
        titleLabel.textColor = model.isSelected ? .textPrimory : .textSecondary
        costLabel.textColor = model.isSelected ? .textPrimory : .textSecondary
        backgroundPointView.backgroundColor = model.isSelected ? .main.withAlphaComponent(0.16) : .clear
        pointView.backgroundColor = model.isSelected ? .main : .textSecondary
        
        costLabel.textAlignment = .right
        costLabel.setAttributedString(lineHeightMultiple: 1.06, kern: -0.34, string: model.cost)
        costLabel.font = model.isSelected ? .medium1 : .medium2
        titleLabel.setAttributedString(lineHeightMultiple: 1.06, kern: -0.3, string: model.title)
    }
    
    private func setupUI() {
        backgroundColor = .backgroundSecondary
        
        contentView.addSubview(backgroundPointView)
        backgroundPointView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundPointView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundPointView.topAnchor.constraint(equalTo: topAnchor),
            backgroundPointView.widthAnchor.constraint(equalToConstant: .pointBackgroundWidth),
            backgroundPointView.heightAnchor.constraint(equalToConstant: .pointBackgroundWidth)
        ])

        backgroundPointView.addSubview(pointView)
        pointView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pointView.centerXAnchor.constraint(equalTo: backgroundPointView.centerXAnchor),
            pointView.centerYAnchor.constraint(equalTo: backgroundPointView.centerYAnchor),
            pointView.widthAnchor.constraint(equalToConstant: .pointWidth),
            pointView.heightAnchor.constraint(equalToConstant: .pointWidth)
        ])
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: pointView.trailingAnchor, constant: .margin),
            titleLabel.centerYAnchor.constraint(equalTo: pointView.centerYAnchor)
        ])
        
        contentView.addSubview(costLabel)
        costLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            costLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            costLabel.centerYAnchor.constraint(equalTo: pointView.centerYAnchor)
        ])
        
        contentView.addSubview(lineView)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lineView.centerXAnchor.constraint(equalTo: backgroundPointView.centerXAnchor),
            lineView.topAnchor.constraint(equalTo: backgroundPointView.bottomAnchor, constant: .lineMargin),
            lineView.widthAnchor.constraint(equalToConstant: .lineWidth),
            lineView.heightAnchor.constraint(equalToConstant: .lineHeight)
        ])
    }
}

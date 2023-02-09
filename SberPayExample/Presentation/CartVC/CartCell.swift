//
//  CartCell.swift
//  SberPay
//
//  Created by Alexander Ipatov on 07.11.2022.
//

import UIKit

private extension CGFloat {
    static let corner = 25.0
    static let topMargin = 15.0
    static let sideMargin = 20.0
}

final class CartCell: UITableViewCell {
    static var reuseID: String { "CartCell" }
    
    private lazy var containerView = UIView()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 2
        view.textColor = .black
        return view
    }()
    
    private lazy var costLabel: UILabel = {
        let view = UILabel()
        view.textColor = .black
        view.font.withSize(15)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(with title: String, cost: Int) {
        titleLabel.text = title
        costLabel.text = "\(String(cost)) p"
        setupUI()
    }
    
    func setupUI() {
        let colorArr: [UIColor] = [.red, .yellow, .blue, .green, .magenta, .orange, .purple]
        containerView.backgroundColor = colorArr.randomElement()?.withAlphaComponent(0.1)
        containerView.layer.cornerRadius = CGFloat.corner
        backgroundColor = .white
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(costLabel)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                               constant: .topMargin),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                   constant: .sideMargin),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                    constant: -.sideMargin),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                  constant: -.topMargin)
        ])
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor,
                                            constant: .topMargin),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,
                                                constant: .sideMargin),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,
                                                 constant: -.sideMargin)
        ])
        
        costLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            costLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                           constant: .topMargin),
            costLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,
                                               constant: .sideMargin),
            costLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,
                                                constant: -.sideMargin),
            costLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor,
                                              constant: -.topMargin)
        ])
    }
}

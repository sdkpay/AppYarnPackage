//
//  CartCell.swift
//  SPay
//
//  Created by Alexander Ipatov on 07.11.2022.
//

import UIKit

private extension CGFloat {
    static let corner = 25.0
    static let topMargin = 15.0
}

final class CartCell: UITableViewCell {
    static var reuseID: String { "CartCell" }
    
    private lazy var containerView = UIView()
    
    private lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var costLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 2
        view.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        view.font = .systemFont(ofSize: 15, weight: .light)
        view.textAlignment = .left
        return view
    }()
    
    private lazy var bargeImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(named: "delete")
        imageView.contentMode = .center
        return imageView
    }()
    
    private lazy var stepper: CustomStepper = {
       let stepper = CustomStepper()
        return stepper
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(with title: String, cost: Int, icon: UIImage, color: UIColor) {
        titleLabel.text = title
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        if let formattedNumber = formatter.string(from: NSNumber(value: cost)) {
            costLabel.text = "\(String(formattedNumber)) p"
        }
        iconImageView.image = icon
        containerView.backgroundColor = color
        setupUI()
    }
    
    func setupUI() {
        containerView.layer.cornerRadius = CGFloat.corner
        backgroundColor = .white
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(costLabel)
        containerView.addSubview(iconImageView)
        containerView.addSubview(bargeImageView)
        containerView.addSubview(stepper)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                               constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                   constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                    constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                  constant: -6)
        ])
        
        stepper.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stepper.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -16),
            stepper.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            stepper.widthAnchor.constraint(equalToConstant: 64),
            stepper.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0),
            iconImageView.widthAnchor.constraint(equalToConstant: 72)
        ])
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.widthAnchor.constraint(equalToConstant: 158)
        ])
        
        costLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            costLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            costLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            costLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            costLabel.widthAnchor.constraint(equalToConstant: 158)
        ])
        
        bargeImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bargeImageView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -17),
            bargeImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            bargeImageView.widthAnchor.constraint(equalToConstant: 24),
            bargeImageView.heightAnchor.constraint(equalToConstant: 24)
//            bargeImageView.bottomAnchor.constraint(equalTo: stepper.topAnchor, constant: -24)
        ])
    }
}

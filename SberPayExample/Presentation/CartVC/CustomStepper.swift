//
//  CustomStepper.swift
//  SberPay
//
//  Created by Alexander Ipatov on 07.11.2022.
//

import UIKit

final class CustomStepper: UIView {
    
    private lazy var decrimentButton: UIButton = {
        let button = UIButton()
        button.setImage(nil, for: .normal)
        button.setTitle("+", for: .normal)
        button.setTitleColor(UIColor(red: 251 / 255, green: 137 / 255, blue: 78 / 255, alpha: 1), for: .normal)
        return button
    }()
    
    private lazy var incrimentButton: UIButton = {
        let button = UIButton()
        button.setImage(nil, for: .normal)
        button.setTitle("-", for: .normal)
        button.setTitleColor(UIColor(red: 251 / 255, green: 137 / 255, blue: 78 / 255, alpha: 1), for: .normal)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "1"
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .init(red: 1, green: 1, blue: 1, alpha: 0.6)
        layer.cornerRadius = 8
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(incrimentButton)
        addSubview(decrimentButton)
        addSubview(titleLabel)
        
        incrimentButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            incrimentButton.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            incrimentButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            incrimentButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3),
            incrimentButton.widthAnchor.constraint(equalToConstant: 11)
        ])
        
        decrimentButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            decrimentButton.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            decrimentButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            decrimentButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3),
            decrimentButton.widthAnchor.constraint(equalToConstant: 11)
        ])
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            titleLabel.trailingAnchor.constraint(equalTo: decrimentButton.leadingAnchor, constant: -13),
            titleLabel.leadingAnchor.constraint(equalTo: incrimentButton.trailingAnchor, constant: 13),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3)
        ])
    }
}

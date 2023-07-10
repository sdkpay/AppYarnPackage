//
//  PaymentSCell.swift
//  SPay
//
//  Created by Alexander Ipatov on 07.11.2022.
//

import UIKit

final class PaymentSCell: UITableViewCell {    
    private var mainView: UIView = {
       let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = .clear
        return view
    }()
    
    private var contentImageView: UIImageView = {
       let view = UIImageView()
        view.image = UIImage(named: "sberPay")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(mainView)
        mainView.addSubview(contentImageView)
        
        mainView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mainView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        contentImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentImageView.topAnchor.constraint(equalTo: mainView.topAnchor),
            contentImageView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            contentImageView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            contentImageView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor)
        ])
    }
}

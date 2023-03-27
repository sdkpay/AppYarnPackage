//
//  ContentView.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 07.12.2022.
//

import UIKit

private extension CGFloat {
    static let height = 72.0
    static let corner = 8.0
}

class ContentView: UIView {
    init() {
        super.init(frame: .zero)
        setupUI()
        let tapGr = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tapGr)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var action: Action?
    
    @objc
    private func tapped() {
        action?()
    }
    
    private func setupUI() {
        backgroundColor = .backgroundSecondary
        layer.cornerRadius = .corner

        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: .height)
        ])
    }
}

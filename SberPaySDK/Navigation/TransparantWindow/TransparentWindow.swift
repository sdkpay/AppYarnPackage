//
//  TransparentWindow.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 15.11.2022.
//

import UIKit

final class TransparentWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view === self || view === rootViewController?.view || view === rootViewController?.view.subviews.first ? nil : view
    }
    
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.2)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundView.alpha = 0
        addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

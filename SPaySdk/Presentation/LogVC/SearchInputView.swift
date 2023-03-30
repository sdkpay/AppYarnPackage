//
//  SearchInputView.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 30.03.2023.
//

import UIKit

private extension CGFloat {
    static let buttonWidth = 40.0
}

@available(iOS 13.0, *)
private extension UIImage {
    static let up = UIImage(systemName: "chevron.up")
    static let down = UIImage(systemName: "chevron.down")
}

final class SearchInputView: UIView {
    private lazy var infoLabel: UILabel = {
        let view = UILabel()
        return view
    }()
    
    var upAction: Action?
    
    var downAction: Action?
    
    private lazy var nextButton: ActionButton = {
        let view = ActionButton()
        if #available(iOS 13.0, *) {
            view.setImage(.down, for: .normal)
        }
        view.addAction {
            self.downAction?()
        }
        return view
    }()
    
    private lazy var backButton: ActionButton = {
        let view = ActionButton()
        if #available(iOS 13.0, *) {
            view.setImage(.up, for: .normal)
        }
        view.addAction {
            self.upAction?()
        }
        return view
    }()
    
    private lazy var countLabel: UILabel = {
        let view = UILabel()
        return view
    }()
    
    init() {
        super.init(frame: CGRect(x: 0,
                                 y: 0,
                                 width: UIScreen.main.bounds.width,
                                 height: 40))
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setResultsNum(current: Int, count: Int) {
        countLabel.text = "Найдено \(current) из \(count)"
    }
    
    func setupUI() {
        backgroundColor = .backgroundSecondary
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: .buttonWidth)
        ])

        addSubview(countLabel)
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: topAnchor),
            countLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            countLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextButton.topAnchor.constraint(equalTo: topAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: .buttonWidth),
            nextButton.heightAnchor.constraint(equalToConstant: .buttonWidth),
            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            nextButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: topAnchor),
            backButton.widthAnchor.constraint(equalToConstant: .buttonWidth),
            backButton.heightAnchor.constraint(equalToConstant: .buttonWidth),
            backButton.trailingAnchor.constraint(equalTo: nextButton.leadingAnchor),
            backButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

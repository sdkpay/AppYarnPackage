//
//  NotEnoughtHeaderView.swift
//  SPaySdk
//
//  Created by Михаил Серёгин on 27.03.2024.
//

import UIKit

private extension CGFloat {
    static let verticalInset = 16.0
}

final class NotEnoughtHeaderView: UIView {

    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.addArrangedSubview(titleLabel)
        view.addArrangedSubview(subtitleLabel)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = .medium5
        view.textColor = .textPrimory
        view.textAlignment = .center
        view.text = "На этих картах не хватает денег"
        return view
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = .medium5
        view.textColor = .textSecondary
        view.textAlignment = .center
        view.text = "Их выбрать нельзя"
        return view
    }()
    
    private var checkTapped: BoolAction?
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        overrideUserInterfaceStyle = .light
        stackView
            .add(toSuperview: self)
            .touchEdge(.top, toSuperviewEdge: .top)
            .touchEdge(.left, toSuperviewEdge: .left)
            .touchEdge(.right, toSuperviewEdge: .right)
            .touchEdge(.bottom, toSuperviewEdge: .bottom, withInset: .verticalInset)
    }
}

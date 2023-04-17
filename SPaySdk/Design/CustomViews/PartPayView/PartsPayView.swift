//
//  PartsPayView.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 14.04.2023.
//

import UIKit

struct PartModel {
    let title: String
    let cost: String
    let isSelected: Bool
    let hideLine: Bool
}

final class PartsPayView: UIView {
    private lazy var partsStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        return view
    }()
    
    private lazy var finalLabel: UILabel = {
       let view = UILabel()
        return view
    }()
    
    init(with patrs: [PartModel], totalCost: String) {
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configStack() {
    }
    
    private func setupUI() {
        addSubview(partsStack)
    }
}

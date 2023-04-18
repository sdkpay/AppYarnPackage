//
//  PartsPayView.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 14.04.2023.
//

import UIKit

//struct PartModel {
//    let title: String
//    let cost: String
//    let isSelected: Bool
//    let hideLine: Bool
//}
//
//private extension CGFloat {
//    static let topMargin = 20.0
//}
//
//final class PartsPayView: BaseView {
//    private lazy var partsStack: UIStackView = {
//        let view = UIStackView()
//        view.axis = .vertical
//        return view
//    }()
//    
//    private lazy var finalLabel: UILabel = {
//        let view = UILabel()
//        view.font = .bodi1
//        view.textColor = .textPrimory
//        view.text = .PayPart.final
//        return view
//    }()
//    
//    private lazy var finalCostLabel: UILabel = {
//       let view = UILabel()
//        view.font = .bodi1
//        view.textColor = .textPrimory
//        return view
//    }()
//    
//   // private let parts: [PartModel]
//    
//    init() {
//        super.init(frame: .zero)
//    }
//    
//    func config(with patrs: [PartModel], totalCost: String) {
//        finalCostLabel.text = totalCost
//        configStack(with: patrs)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func configStack(with parts: [PartModel]) {
//        parts.forEach { model in
//            let view = PartView(model: model)
//            partsStack.addArrangedSubview(view)
//        }
//    }
//    
//    private func setupUI() {
//        addSubview(partsStack)
//        addSubview(finalLabel)
//        addSubview(finalCostLabel)
//        
//        partsStack.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            partsStack.topAnchor.constraint(equalTo: topAnchor, constant: .topMargin),
//            partsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .margin),
//            partsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.margin),
//            partsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.topMargin)
//        ])
//        
//        finalLabel.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            finalLabel.topAnchor.constraint(equalTo: partsStack.bottomAnchor, constant: .margin),
//            finalLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .margin),
//            finalLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.topMargin)
//        ])
//
//        finalCostLabel.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            finalCostLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.margin),
//            finalCostLabel.centerYAnchor.constraint(equalTo: finalLabel.centerYAnchor)
//        ])
//    }
//}

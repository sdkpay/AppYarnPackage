//
//  CardsViewBuilder.swift
//  SPaySdk
//
//  Created by Арсений on 11.07.2023.
//

import UIKit

private extension CGFloat {
    static let topMargin = 20.0
    static let tableMargin = 12.0
    static let bottomMargin = 58.0
    static let rowHeight = 88.0
}

private extension CardsViewBuilder {
    enum Consts {
        static let offSet: CGFloat = 16.0
        enum Title {
            static let font = UIFont.medium5
            static let textColor = UIColor.textSecondary
            static let text = String(stringLiteral: Strings.Cards.title)
            
            static let topOffSet: CGFloat = 40.0
            static let rightOffSet = Consts.offSet
        }
        
        enum Cost {
            static let font = UIFont.header3
            static let textColor = UIColor.textPrimory
            static let text = String(stringLiteral: Strings.Cards.title)
            
            static let topOffSet: CGFloat = 4.0
            static let rightOffSet = Consts.offSet
        }
        
        enum TableView {
            static let backgroundColor = UIColor.backgroundPrimary
            static let rowHeight: CGFloat = 74.0
            
            static let bottomOffSet: CGFloat = 54.0
            static let rightOffSet: CGFloat = Consts.offSet
            static let topOffSet: CGFloat = 20.0
        }
    }
}

final class CardsViewBuilder {
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = Consts.Title.font
        view.textColor = Consts.Title.textColor
        view.text = Consts.Title.text
        view.textAlignment = .center
        view.height(view.requiredHeight)
        return view
    }()
    
    private(set) lazy var costLabel: UILabel = {
       let view = UILabel()
        view.font = Consts.Cost.font
        view.textColor = Consts.Cost.textColor
        view.text = Consts.Cost.text
        view.textAlignment = .center
        view.sizeToFit()
        view.height(view.requiredHeight)
        return view
    }()
    
    private lazy var stackLabel: UIStackView = {
       let view = UIStackView()
        view.axis = .vertical
        view.spacing = 4
        view.addArrangedSubview(titleLabel)
        view.addArrangedSubview(costLabel)
        return view
    }()
    
    private(set) lazy var tableView: ContentTableView = {
        let view = ContentTableView()
        view.register(cellClass: CardCell.self)
        view.separatorStyle = .none
        view.backgroundColor = .clear
        view.backgroundView?.backgroundColor = Consts.TableView.backgroundColor
        view.showsVerticalScrollIndicator = false
        view.rowHeight = Consts.TableView.rowHeight
        return view
    }()
    
    func setupUI(view: UIView) {
        stackLabel
            .add(toSuperview: view)
            .touchEdge(.top,
                       toSameEdgeOfView: view,
                       withInset: Consts.Title.topOffSet)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Consts.offSet)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Consts.offSet)

        tableView
            .add(toSuperview: view)
            .touchEdge(.top, toEdge: .bottom, ofView: stackLabel, withInset: Consts.TableView.topOffSet)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Consts.TableView.rightOffSet)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Consts.TableView.rightOffSet)
            .touchEdge(.bottom, toSuperviewEdge: .bottom, withInset: Consts.TableView.bottomOffSet)
    }
}

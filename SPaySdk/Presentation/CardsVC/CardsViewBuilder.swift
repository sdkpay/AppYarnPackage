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
    static let rowHeight = 84.0
}

private extension CardsViewBuilder {
    enum Consts {
        static let offSet: CGFloat = 16.0
        enum Title {
            static let font = UIFont.bodi2
            static let textColor = UIColor.textSecondary
            static let text = String(stringLiteral: Strings.Cards.title)
            
            static let topOffSet: CGFloat = 20.0
            static let rightOffSet = Consts.offSet
        }
        
        enum TableView {
            static let backgroundColor = UIColor.backgroundPrimary
            static let rowHeight: CGFloat = 84.0
            
            static let bottomOffSet: CGFloat = 58.0
            static let rightOffSet: CGFloat = Consts.offSet
            static let topOffSet: CGFloat = 12.0
        }
    }
}

final class CardsViewBuilder {
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = Consts.Title.font
        view.textColor = Consts.Title.textColor
        view.text = Consts.Title.text
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
    
    func setupUI(view: UIView, logoImage: UIImageView) {
        titleLabel
            .add(toSuperview: view)
            .touchEdge(.top, toEdge: .bottom, ofView: logoImage, withInset: Consts.Title.topOffSet)
            .touchEdge(.left, toEdge: .left, ofView: logoImage)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .margin)

        tableView
            .add(toSuperview: view)
            .touchEdge(.top, toEdge: .bottom, ofView: titleLabel, withInset: Consts.TableView.topOffSet)
            .touchEdge(.left, toEdge: .left, ofView: titleLabel)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Consts.TableView.rightOffSet)
            .touchEdge(.bottom, toSuperviewEdge: .bottom, withInset: Consts.TableView.bottomOffSet)
    }
}

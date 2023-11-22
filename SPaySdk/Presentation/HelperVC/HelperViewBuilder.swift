//
//  HelperViewBuilder.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 19.11.2023.
//

import UIKit

private extension CGFloat {
    static let topMargin = 20.0
    static let tableMargin = 12.0
    static let bottomMargin = 58.0
    static let rowHeight = 84.0
}

private extension HelperViewBuilder {
    enum Consts {
        static let offSet: CGFloat = 16.0
        
        enum Image {
            static let font = UIFont.medium5
            static let textColor = UIColor.backgroundPrimary
            static let text = UserDefaults.localization?.authTitle
            
            static let topOffSet: CGFloat = 40.0
            static let rightOffSet = Consts.offSet
        }
        
        enum Title {
            static let font = UIFont.medium5
            static let textColor = UIColor.backgroundPrimary
            static let text = UserDefaults.localization?.authTitle
            
            static let topOffSet: CGFloat = 40.0
            static let rightOffSet = Consts.offSet
        }
        
        enum Subtitle {
            static let font = UIFont.bodi2
            static let textColor = UIColor.backgroundPrimary
            
            static let topOffSet: CGFloat = 6.0
            static let rightOffSet = Consts.offSet
        }
        
        enum MainButton {
            static let font = UIFont.subheadline
            static let textColor = UIColor.backgroundPrimary
            static let heidgt: CGFloat = .defaultButtonHeight
            
            static let bottomOffSet: CGFloat = 34.0
            static let topOffSet: CGFloat = 8.0
        }
        
        enum BackButton {
            static let font = UIFont.subheadline
            static let textColor = UIColor.backgroundPrimary
            static let heidgt: CGFloat = .defaultButtonHeight
            
            static let bottomOffSet: CGFloat = 34.0
            static let topOffSet: CGFloat = 8.0
        }
    }
}

final class HelperViewBuilder {

    private var backButtonDidTap: Action
    private var actionButtonDidTap: Action
    
    private lazy var imageView: UIImageView = {
       let view = UIImageView()
        view.image = Asset.background.image
        return view
    }()

    private(set) lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = Consts.Title.font
        view.textColor = Consts.Title.textColor
        view.text = Consts.Title.text
        view.textAlignment = .center
        return view
    }()
    
    private(set) lazy var subTitleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = Consts.Title.font
        view.textColor = Consts.Title.textColor
        view.text = Consts.Title.text
        view.textAlignment = .center
        return view
    }()
    
    private lazy var actionButton: ActionButton = {
        let view = ActionButton()
        view.setTitle(Strings.BankAppPicker.close, for: .normal)
        view.setTitleColor(Consts.BackButton.textColor, for: .normal)
        view.titleLabel?.font = Consts.BackButton.font
        view.addAction(backButtonDidTap)
        return view
    }()

    
    private lazy var closeButton: ActionButton = {
        let view = ActionButton()
        view.setTitle(Strings.BankAppPicker.close, for: .normal)
        view.setTitleColor(Consts.BackButton.textColor, for: .normal)
        view.titleLabel?.font = Consts.BackButton.font
        view.addAction(backButtonDidTap)
        return view
    }()
    
    init(actionButtonDidTap: @escaping Action, backButtonDidTap: @escaping Action) {
        self.backButtonDidTap = backButtonDidTap
        self.actionButtonDidTap = actionButtonDidTap
    }
    
    func setupUI(view: UIView) {
        
        imageView
            .add(toSuperview: view)
            .touchEdgesToSuperview([.bottom, .left, .right, .top])
        
        titleLabel
            .add(toSuperview: view)
            .touchEdge(.top, toSameEdgeOfView: view, withInset: Consts.Title.topOffSet)
            .touchEdge(.left, toSameEdgeOfView: view, withInset: .margin)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .margin)
        
        subTitleLabel
            .add(toSuperview: view)
            .touchEdge(.top, toSameEdgeOfView: view, withInset: Consts.Title.topOffSet)
            .touchEdge(.left, toSameEdgeOfView: view, withInset: .margin)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .margin)
        
        actionButton
            .add(toSuperview: view)
            .touchEdge(.top, toEdge: .bottom, ofView: subTitleLabel, withInset: Consts.BackButton.topOffSet)
            .touchEdge(.left, toEdge: .left, ofView: titleLabel)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .margin)
            .touchEdge(.bottom, toSuperviewEdge: .bottom, withInset: Consts.BackButton.bottomOffSet)
        
        closeButton
            .add(toSuperview: view)
            .touchEdge(.top, toEdge: .bottom, ofView: actionButton, withInset: Consts.BackButton.topOffSet)
            .touchEdge(.left, toEdge: .left, ofView: titleLabel)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .margin)
            .touchEdge(.bottom, toSuperviewEdge: .bottom, withInset: Consts.BackButton.bottomOffSet)
    }
}


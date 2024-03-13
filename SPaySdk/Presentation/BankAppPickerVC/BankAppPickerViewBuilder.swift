//
//  BankAppPickerViewBuilder.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 24.10.2023.
//

import UIKit

private extension CGFloat {
    static let topMargin = 20.0
    static let tableMargin = 12.0
    static let bottomMargin = 58.0
    static let rowHeight = 84.0
}

private extension BankAppPickerViewBuilder {
    enum Consts {
        static let offSet: CGFloat = 16.0
        enum Title {
            static let font = UIFont.medium1
            static let textColor = UIColor.textPrimory
            static let text = UserDefaults.localization?.authTitle
            
            static let height: CGFloat = 56.0
            static let topOffSet: CGFloat = 28.0
            static let rightOffSet = Consts.offSet
        }
        
        enum Subtitle {
            static let font = UIFont.medium3
            static let textColor = UIColor.textSecondary
            static let text = UserDefaults.localization?.authTitle
            
            static let topOffSet: CGFloat = 6.0
            static let rightOffSet = Consts.offSet
        }
        
        enum TableView {
            static let backgroundColor = UIColor.backgroundPrimary
            static let rowHeight: CGFloat = 84.0
            
            static let bottomOffSet: CGFloat = 58.0
            static let rightOffSet: CGFloat = Consts.offSet
            static let topOffSet: CGFloat = 20.0
        }
        
        enum BackButton {
            static let font = UIFont.subheadline
            static let textColor = UIColor.textPrimory
            static let heidgt: CGFloat = 48.0
            
            static let bottomOffSet: CGFloat = 34.0
            static let topOffSet: CGFloat = 4.0
        }
    }
}

final class BankAppPickerViewBuilder {

    private var backButtonDidTap: Action

    private(set) lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = Consts.Title.font
        view.textColor = Consts.Title.textColor
        view.text = Consts.Title.text
        view.textAlignment = .center
        return view
    }()
    
    private(set) lazy var subtitleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = Consts.Subtitle.font
        view.textColor = Consts.Subtitle.textColor
        view.text = Consts.Subtitle.text
        view.textAlignment = .center
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
    
    init(backButtonDidTap: @escaping Action) {
        self.backButtonDidTap = backButtonDidTap
    }
    
    private(set) lazy var tableView: ContentTableView = {
        let view = ContentTableView()
        view.register(cellClass: BankAppCell.self)
        view.separatorStyle = .none
        view.backgroundColor = .clear
        view.backgroundView?.backgroundColor = Consts.TableView.backgroundColor
        view.showsVerticalScrollIndicator = false
        view.rowHeight = Consts.TableView.rowHeight
        view.isScrollEnabled = false
        return view
    }()
    
    func setupUI(view: UIView) {
        
        titleLabel
            .add(toSuperview: view)
            .touchEdge(.top, toSameEdgeOfView: view, withInset: Consts.Title.topOffSet)
            .touchEdge(.left, toSameEdgeOfView: view, withInset: .margin)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .margin)
            .height(Consts.Title.height, priority: .defaultHigh)
        
        tableView
            .add(toSuperview: view)
            .touchEdge(.top, toEdge: .bottom, ofView: titleLabel, withInset: Consts.TableView.topOffSet)
            .touchEdge(.left, toEdge: .left, ofView: titleLabel)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Consts.TableView.rightOffSet)
        
        closeButton
            .add(toSuperview: view)
            .touchEdge(.top, toEdge: .bottom, ofView: tableView, withInset: Consts.BackButton.topOffSet)
            .touchEdge(.left, toEdge: .left, ofView: titleLabel)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: .margin)
            .height(Consts.BackButton.heidgt)
            .touchEdge(.bottom, toEdge: .bottom, ofGuide: .safeAreaLayout(of: view))
    }
}

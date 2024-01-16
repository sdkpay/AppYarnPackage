//
//  PartPayViewBuilder.swift
//  SPaySdk
//
//  Created by Арсений on 11.07.2023.
//

import UIKit

private extension PartPayViewBuilder {
    enum Consts {
        static let margin: CGFloat = 16.0
        
        enum Label {
            enum Title {
                static let font = UIFont.header2
                static let textColor = UIColor.textPrimory
                
                static let topOffSet: CGFloat = 32.0
                static let leftOffSet: CGFloat = 32.0
                static let rightOffSet: CGFloat = Consts.margin
            }
            
            enum Final {
                static let font = UIFont.medium5
                static let textColor = UIColor.textPrimory
                static let text = Strings.Part.Pay.final
            }
            
            enum FinalCost {
                static let font = UIFont.medium5
                static let textColor = UIColor.textPrimory
            }
        }
        
        enum Button {
            enum Accept {
                static let title = String(stringLiteral: Strings.Accept.title)
                
                static let topOffSet: CGFloat = 20.0
                static let leftOffSet: CGFloat = Consts.margin
                static let rightOffSet: CGFloat = Consts.margin
                static let bottomOffSet: CGFloat = 10.0
                static let height: CGFloat = 56.0
            }
            
            enum Cancel {
                static let title = String(stringLiteral: Strings.Part.Pay.Cancel.title)
                
                static let topOffSet: CGFloat = 20.0
                static let leftOffSet: CGFloat = Consts.margin
                static let rightOffSet: CGFloat = Consts.margin
                static let bottomOffSet: CGFloat = 44.0
                static let height: CGFloat = 56.0
            }
        }
        
        enum TableView {
            
            enum Background {
                static let rowHeight: CGFloat = 45.0
                
                static let topOffSet: CGFloat = 6.0
                static let leftOffSet: CGFloat = Consts.margin
                static let rightOffSet: CGFloat = Consts.margin
            }
            
            enum Parts {
                static let topOffSet: CGFloat = 20.0
                static let leftOffSet: CGFloat = Consts.margin
                static let rightOffSet: CGFloat = Consts.margin
            }
        }
        
        enum Stack {
            static let topOffSet: CGFloat = 20.0
            static let leftOffSet: CGFloat = 22.0
            static let rightOffSet: CGFloat = Consts.margin
            static let bottomOffSet: CGFloat = Consts.margin
            static let height: CGFloat = Consts.margin
        }
        
        enum View {
            static let topOffSet: CGFloat = 4.0
            static let leftOffSet: CGFloat = Consts.margin
            static let rightOffSet: CGFloat = Consts.margin
            static let bottomOffSet: CGFloat = 20.0
        }
    }
}

final class PartPayViewBuilder {
    private var acceptButtonTapped: Action
    private var backButtonTapped: Action
    
    private(set) lazy var titleLabel: UILabel = {
       let view = UILabel()
        view.font = Consts.Label.Title.font
        view.setAttributedString(lineHeightMultiple: 1.12,
                                 kern: -0.3,
                                 string: Strings.Part.Pay.title)
        view.textColor = Consts.Label.Title.textColor
        view.height(view.requiredHeight)
        return view
    }()
    
    private(set) lazy var acceptButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .full)
        view.setTitle(Consts.Button.Accept.title, for: .normal)
        view.addAction(acceptButtonTapped)
        return view
    }()
    
    private(set) lazy var cancelButton: DefaultButton = {
        let view = DefaultButton(buttonAppearance: .info)
        view.setTitle(Consts.Button.Cancel.title, for: .normal)
        view.addAction(backButtonTapped)
        return view
    }()
    
    private(set) lazy var agreementView = CheckView()

    private(set) lazy var finalLabel: UILabel = {
        let view = UILabel()
        view.font = Consts.Label.Final.font
        view.textColor = Consts.Label.Final.textColor
        view.text = Consts.Label.Final.text
        return view
    }()
    
    private(set) lazy var finalCostLabel: UILabel = {
       let view = UILabel()
        view.font = Consts.Label.FinalCost.font
        view.textColor = Consts.Label.FinalCost.textColor
        return view
    }()
    
    private(set) lazy var finalStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.addArrangedSubview(finalLabel)
        view.addArrangedSubview(finalCostLabel)
        return view
    }()
    
    private(set) lazy var partsTableView: ContentTableView = {
        let view = ContentTableView()
        view.register(cellClass: PartCell.self)
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.isScrollEnabled = false
        view.backgroundColor = .clear
        view.rowHeight = Consts.TableView.Background.rowHeight
        return view
    }()
    
    private(set) lazy var backgroundTableView: UIView = {
        let view = UIView()
        view.setupForBase()
        return view
    }()
    
    init(acceptButtonTapped: @escaping Action, backButtonTapped: @escaping Action) {
        self.acceptButtonTapped = acceptButtonTapped
        self.backButtonTapped = backButtonTapped
    }
    
    func setupUI(view: UIView) {
        
        acceptButton
            .add(toSuperview: view)
        
        titleLabel
            .add(toSuperview: view)
            .touchEdge(.top, toSuperviewEdge: .top, withInset: Consts.Label.Title.topOffSet)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Consts.Label.Title.leftOffSet)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Consts.Label.Title.rightOffSet)

        backgroundTableView
            .add(toSuperview: view)
            .touchEdge(.top, toEdge: .bottom, ofView: titleLabel, withInset: Consts.TableView.Background.topOffSet)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Consts.TableView.Background.leftOffSet)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Consts.TableView.Background.rightOffSet)
        
        partsTableView
            .add(toSuperview: backgroundTableView)
            .touchEdge(.top, toEdge: .top, ofView: backgroundTableView, withInset: Consts.TableView.Parts.topOffSet)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Consts.TableView.Parts.leftOffSet)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Consts.TableView.Parts.rightOffSet)
        
        finalStack
            .add(toSuperview: backgroundTableView)
            .touchEdge(.top, toEdge: .bottom, ofView: partsTableView)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Consts.Stack.leftOffSet)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Consts.Stack.rightOffSet)
            .touchEdge(.bottom, toSuperviewEdge: .bottom, withInset: Consts.Stack.bottomOffSet)
            .height(Consts.Stack.height)

        agreementView
            .add(toSuperview: view)
            .touchEdge(.top, toEdge: .bottom, ofView: backgroundTableView, withInset: Consts.View.topOffSet)
            .touchEdge(.left, toSameEdgeOfView: finalStack)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Consts.View.rightOffSet)
            .touchEdge(.bottom, toEdge: .top, ofView: acceptButton, withInset: Consts.View.bottomOffSet)
            
        cancelButton
            .add(toSuperview: view)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Consts.Button.Cancel.leftOffSet)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Consts.Button.Cancel.rightOffSet)
            .touchEdge(.bottom, toSuperviewEdge: .bottom, withInset: Consts.Button.Cancel.bottomOffSet)
            .height(Consts.Button.Cancel.height)

        acceptButton
            .add(toSuperview: view)
            .height(Consts.Button.Accept.height)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Consts.Button.Accept.leftOffSet)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Consts.Button.Accept.rightOffSet)
            .touchEdge(.bottom, toEdge: .top, ofView: cancelButton, withInset: Consts.Button.Accept.bottomOffSet)
    }
}

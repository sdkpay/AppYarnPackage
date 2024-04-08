//
//  PartPayModuleViewBuilder.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 01.03.2024.
//

import UIKit

private extension PartPayModuleViewBuilder {
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
                static let text = Strings.PartPay.final
            }
            
            enum FinalCost {
                static let font = UIFont.medium5
                static let textColor = UIColor.textPrimory
            }
        }
        
        enum Button {
            enum Accept {
                static let title = String(stringLiteral: Strings.PartPay.Accept.title)
                
                static let topOffSet: CGFloat = 20.0
                static let leftOffSet: CGFloat = Consts.margin
                static let rightOffSet: CGFloat = Consts.margin
                static let bottomOffSet: CGFloat = 10.0
                static let height: CGFloat = 56.0
            }
            
            enum Cancel {
                static let title = String(stringLiteral: Strings.PartPay.Cancel.title)
                
                static let topOffSet: CGFloat = 20.0
                static let leftOffSet: CGFloat = Consts.margin
                static let rightOffSet: CGFloat = Consts.margin
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
                static let leftOffSet: CGFloat = Consts.margin * 2
                static let rightOffSet: CGFloat = Consts.margin * 2
            }
        }
        
        enum Stack {
            static let topOffSet: CGFloat = 20.0
            static let leftOffSet: CGFloat = 22.0 + Consts.margin
            static let rightOffSet: CGFloat = Consts.margin * 2
            static let bottomOffSet: CGFloat = Consts.margin
            static let height: CGFloat = Consts.margin
        }
        
        enum View {
            static let topOffSet: CGFloat = 4.0
            static let leftOffSet: CGFloat = Consts.margin
            static let rightOffSet: CGFloat = Consts.margin
            static let bottomOffSet: CGFloat = 12.0
        }
    }
}

final class PartPayModuleViewBuilder {
    
    private(set) lazy var titleLabel: UILabel = {
       let view = UILabel()
        view.font = Consts.Label.Title.font
        view.setAttributedString(lineHeightMultiple: 1.12,
                                 kern: -0.3,
                                 string: Strings.PartPay.title)
        view.textColor = Consts.Label.Title.textColor
        view.height(view.requiredHeight)
        return view
    }()
    
    private(set) lazy var agreementView = CheckView()
    
    private(set) lazy var commissionLabel = CommissionLabel()

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
        view.textAlignment = .right
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
        view.backgroundColor = .clear
        view.rowHeight = Consts.TableView.Background.rowHeight
        return view
    }()
    
    private(set) lazy var backgroundTableView: UIView = {
        let view = UIView()
        view.setupForBase()
        return view
    }()
    
    func setupUI(view: UIView, needCommissionLabel: Bool) {
        titleLabel
            .add(toSuperview: view)
            .touchEdge(.top, toSuperviewEdge: .top, withInset: Consts.Label.Title.topOffSet)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Consts.Label.Title.leftOffSet)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Consts.Label.Title.rightOffSet)
        
        if needCommissionLabel {
            
            commissionLabel
                .add(toSuperview: view)
                .touchEdge(.top, toEdge: .bottom, ofView: titleLabel, withInset: Consts.TableView.Background.topOffSet)
                .touchEdge(.left, toSuperviewEdge: .left, withInset: Consts.Label.Title.leftOffSet)
        }
        
        backgroundTableView
            .add(toSuperview: view)
            .touchEdge(.left, toSuperviewEdge: .left)
            .touchEdge(.right, toSuperviewEdge: .right)
        
        if needCommissionLabel {
            backgroundTableView
                .touchEdge(.top, toEdge: .bottom, ofView: commissionLabel, withInset: Consts.TableView.Background.topOffSet)
        } else {
            backgroundTableView
                .touchEdge(.top, toEdge: .bottom, ofView: titleLabel, withInset: Consts.TableView.Background.topOffSet)
        }
        
        partsTableView
            .add(toSuperview: backgroundTableView)
            .touchEdge(.top, toEdge: .top, ofView: backgroundTableView, withInset: Consts.TableView.Parts.topOffSet)
            .touchEdge(.left, toEdge: .left, ofView: view, withInset: Consts.TableView.Parts.leftOffSet)
            .touchEdge(.right, toEdge: .right, ofView: view, withInset: Consts.TableView.Parts.rightOffSet)
        
        finalStack
            .add(toSuperview: backgroundTableView)
            .touchEdge(.top, toEdge: .bottom, ofView: partsTableView)
            .touchEdge(.left, toEdge: .left, ofView: view, withInset: Consts.Stack.leftOffSet)
            .touchEdge(.right, toEdge: .right, ofView: view, withInset: Consts.Stack.rightOffSet)
            .touchEdge(.bottom, toSuperviewEdge: .bottom, withInset: Consts.Stack.bottomOffSet)
            .height(Consts.Stack.height)

        agreementView
            .add(toSuperview: view)
            .touchEdge(.top, toEdge: .bottom, ofView: backgroundTableView, withInset: Consts.View.topOffSet)
            .touchEdge(.left, toSameEdgeOfView: finalStack)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Consts.View.rightOffSet)
            .touchEdge(.bottom, toEdge: .bottom, ofView: view, withInset: Consts.View.bottomOffSet)
    }
}

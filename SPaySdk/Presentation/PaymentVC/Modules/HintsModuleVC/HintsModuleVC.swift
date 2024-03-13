//
//  HintsModuleVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 04.03.2024.
//

import UIKit

private extension CGFloat {
    
    static let sideOffSet: CGFloat = 32.0
}

protocol IHintsModuleVC {
    
    func setHint(with text: String)
    func setHints(with texts: [String])
}

final class HintsModuleVC: ModuleVC, IHintsModuleVC {
    
    private var presenter: HintsModulePresenting
    
    private(set) lazy var hintsStackView: HintsStackView = {
        let view = HintsStackView()
        return view
    }()
    
    init(_ presenter: HintsModulePresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        setupUI()
    }
    
    func setHint(with text: String) {
        
        hintsStackView.add(text)
    }

    func setHints(with texts: [String]) {
        
        hintsStackView.setStack(texts)
    }

    private func setupUI() {
        
        hintsStackView
            .add(toSuperview: view)
            .touchEdge(.top, toEdge: .top, ofView: view)
            .touchEdge(.left, toEdge: .left, ofView: view, withInset: Cost.Hint.margin)
            .touchEdge(.right, toEdge: .right, ofView: view, withInset: Cost.Hint.margin)
            .touchEdge(.bottom, toEdge: .bottom, ofView: view, withInset: Cost.Hint.bottomMax, usingRelation: .lessThanOrEqual)
            .touchEdge(.bottom,
                       toEdge: .bottom,
                       ofView: view,
                       withInset: Cost.Hint.bottomMin,
                       usingRelation: .greaterThanOrEqual,
                       priority: .defaultLow)
    }
}

private extension HintsModuleVC {
    enum Cost {
        static let sideOffSet: CGFloat = 32.0
        static let height = 56.0
        
        enum Hint {
            static let bottomMax = 20.0
            static let bottomMin = 8.0
            static let margin = 36.0
        }
    }
}

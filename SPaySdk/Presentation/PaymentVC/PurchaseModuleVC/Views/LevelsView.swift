//
//  LevelsView.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 06.12.2023.
//

import UIKit

private extension CGFloat {
    
    static let levelWidth = 16.0
    static let levelRadius = 3.0
    static let levelHeight = 6.0
    static let levelSpacing = 5.0
}

private extension TimeInterval {
    
    static let animationDuration = 0.25
}
 
private final class LevelView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        backgroundColor = Asset.grayLight.color
        layer.masksToBounds = true
        layer.cornerRadius = .levelRadius
    }
}

final class LevelsView: UIView {
    
    private var levelsCount: Int = 1
    
    private var levelViews = [LevelView]()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fill
        view.spacing = .levelSpacing
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(levelsCount: Int, selectedViewIndex: Int) {
        self.levelsCount = levelsCount
        if levelsCount > 0 {
            addLevels()
        }
        setupUI()
        selectView(at: selectedViewIndex)
    }
    
    private func addLevels() {
        
        for _ in 1...levelsCount {
    
            let levelView = LevelView()
            levelView.size(.init(width: .levelWidth, height: .levelHeight))
            
            levelViews.append(levelView)
            stackView.addArrangedSubview(levelView)
        }
    }

    func selectView(at index: Int) {
        
        guard index <= levelViews.count - 1 else { return }
        
        let newView = levelViews[index]
        
        UIView.animate(withDuration: .animationDuration) {
            
            self.levelViews.filter({ $0 != newView }).forEach({ $0.backgroundColor = Asset.grayLight.color })
            newView.backgroundColor = .main
        }
    }

    private func setupUI() {

        stackView
            .add(toSuperview: self)
            .touchEdgesToSuperview()
    }
}

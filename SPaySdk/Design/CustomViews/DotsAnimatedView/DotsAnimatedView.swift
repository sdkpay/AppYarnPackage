//
//  PointsAnimatedView.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 20.11.2023.
//

import UIKit

private extension CGFloat {
    
    static let dotWidth = 6.0
    static let dotSpacing = 5.0
}
 
private final class DotView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        backgroundColor = .textPrimory
        layer.masksToBounds = true
        layer.cornerRadius = .dotWidth / 2
    }
}

final class DotsAnimatedView: UIView {
    
    private var dotsCount = 3
    private lazy var dots = [DotView]()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fill
        view.axis = .horizontal
        view.alignment = .center
        view.spacing = .dotSpacing
        return view
    }()

    init() {
        super.init(frame: .zero)
        addDots()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addDots() {
        
        for _ in 1...dotsCount {
    
            let dotView = DotView()
            dotView.size(.init(width: .dotWidth, height: .dotWidth))
            
            dots.append(dotView)
            stackView.addArrangedSubview(dotView)
        }
    }
    
    func startAnimation() {
        
        let jumpDuration: Double = 0.30
        let delayDuration: Double = 1.25
        let totalDuration: Double = delayDuration + jumpDuration * 2
        
        let jumpRelativeDuration: Double = jumpDuration / totalDuration
        let jumpRelativeTime: Double = delayDuration / totalDuration
        let fallRelativeTime: Double = (delayDuration + jumpDuration) / totalDuration
        
        for (index, dot) in dots.enumerated() {
            let delay = jumpDuration * 2 * TimeInterval(index) / TimeInterval(dotsCount)
            UIView.animateKeyframes(withDuration: totalDuration, delay: delay, options: [.repeat], animations: {
                UIView.addKeyframe(withRelativeStartTime: jumpRelativeTime, relativeDuration: jumpRelativeDuration) {
                    dot.center.y -= 30
                }
                UIView.addKeyframe(withRelativeStartTime: fallRelativeTime, relativeDuration: jumpRelativeDuration) {
                   dot.center.y += 30
                }
            })
        }
    }
    
    private func setupUI() {
        stackView
            .add(toSuperview: self)
            .touchEdge(.bottom, toSuperviewEdge: .bottom)
            .touchEdge(.top, toSuperviewEdge: .top)
            .touchEdge(.left, toSuperviewEdge: .left)
            .touchEdge(.right, toSuperviewEdge: .right)
    }
}

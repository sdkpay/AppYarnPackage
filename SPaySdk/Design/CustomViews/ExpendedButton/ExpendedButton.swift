//
//  ExpendedButton.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 26.04.2023.
//

import UIKit

class ExpendedButton: ActionButton {
    private let x: CGFloat
    private let y: CGFloat

    init(_ x: CGFloat, _ y: CGFloat) {
        self.x = x
        self.y = y
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let expandedBounds = bounds.insetBy(dx: x, dy: y)
        return expandedBounds.contains(point)
    }
}

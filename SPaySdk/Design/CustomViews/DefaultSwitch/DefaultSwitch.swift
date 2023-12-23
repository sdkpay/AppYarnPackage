//
//  DefaultSwitch.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 11.12.2023.
//

import UIKit

final class DefaultSwitch: UISwitch {
    
    let standardHeight: CGFloat = 31
    let standardWidth: CGFloat = 51
    
    private var action: BoolAction?
    
    func addAction(_ action: @escaping BoolAction) {
        self.action = action
        addTarget(self, action: #selector(switchControlChanged), for: .allEvents)
    }
    
    @objc
    private func switchControlChanged() throws {
        action?(self.isOn)
    }
    
    func set(width: CGFloat, height: CGFloat) {
        
        let heightRatio = height / standardHeight
        let widthRatio = width / standardWidth
        
        transform = CGAffineTransform(scaleX: widthRatio, y: heightRatio)
    }
}

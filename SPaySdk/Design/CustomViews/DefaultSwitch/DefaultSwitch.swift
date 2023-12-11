//
//  DefaultSwitch.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 11.12.2023.
//

import UIKit

final class DefaultSwitch: UISwitch {
    
    var OffTint: UIColor? {
        didSet {
            self.tintColor = OffTint
            self.layer.cornerRadius = 16
            self.backgroundColor = OffTint
        }
    }

    private var action: BoolAction?

    func addAction(_ action: @escaping BoolAction) {
        self.action = action
        addTarget(self, action: #selector(switchControlChanged), for: .allEvents)
    }

    @objc
    private func switchControlChanged() throws {
        action?(self.isOn)
    }
}

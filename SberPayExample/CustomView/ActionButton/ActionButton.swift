//
//  ActionButton.swift
//  SPaySdkExample
//
//  Created by Ипатов Александр Станиславович on 25.05.2023.
//

import UIKit

public typealias Action = (() -> Void)

class ActionButton: UIButton {
    private var action: Action?

    func addAction(_ action: @escaping Action) {
        self.action = action
        addTarget(self, action: #selector(useAction), for: .touchUpInside)
    }

    @objc
    private func useAction() throws {
        action?()
    }
}

//
//  ActionButton.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 22.11.2022.
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

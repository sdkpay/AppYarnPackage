//
//  ContentTableView.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 28.12.2022.
//

import UIKit

private extension CGFloat {
    static let maxTableViewHeight = UIScreen.main.bounds.height * 0.73
}

class ContentTableView: UITableView {
    override var contentSize: CGSize {
        didSet {
            fixHeight()
        }
    }

    private lazy var tableHeightConstraint: NSLayoutConstraint = {
        let constraint = heightAnchor.constraint(equalToConstant: 0)
        constraint.priority = .defaultLow
        constraint.isActive = true
        return constraint
    }()

    private func fixHeight() {
        tableHeightConstraint.constant = contentSize.height > .maxTableViewHeight ? .maxTableViewHeight : contentSize.height
    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === panGestureRecognizer else {
            return true
        }
        if contentOffset.y == -contentInset.top,
           panGestureRecognizer.velocity(in: nil).y > 0 {
            return false
        } else if contentOffset.y < -contentInset.top {
            return false
        } else {
            return true
        }
    }
}

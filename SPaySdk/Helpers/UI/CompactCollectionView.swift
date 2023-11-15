//
//  CompactCollectionView.swift
//  SPaySdk
//
//  Created by Арсений on 18.04.2023.
//

import UIKit

class CompactCollectionView: UICollectionView {

    override var contentSize: CGSize {
        didSet {
            fixHeight()
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === panGestureRecognizer else {
            return true
        }

        if contentOffset.y == -contentInset.top, panGestureRecognizer.velocity(in: nil).y > 0 {
            return false
        }

        if contentOffset.y < -contentInset.top {
            return false
        }

        return true
    }

    private lazy var collectionHeightConstraint: NSLayoutConstraint = {
        let constraint = heightAnchor.constraint(equalToConstant: 0)
        constraint.priority = .defaultHigh
        constraint.isActive = true
        return constraint
    }()

    private func fixHeight() {
        var height = contentSize.height
        + contentInset.top
        + contentInset.bottom
        + safeAreaInsets.bottom
        (collectionViewLayout as? UICollectionViewCompositionalLayout).map { height += $0.configuration.interSectionSpacing }
        (collectionViewLayout as? UICollectionViewFlowLayout).map { height += $0.sectionInset.bottom }

        if height != 0 && height != CGFloat.infinity {
            collectionHeightConstraint.constant = height
        }
    }
}

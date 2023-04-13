//
//  UIView+Center.swift
//  SPaySdk
//
//  Created by Арсений on 11.04.2023.
//

import UIKit

public extension UIView {
    
    @discardableResult
    func centerInSuperview(_ axis: SBAxis,
                           withOffset offset: CGFloat = .zero,
                           priority: UILayoutPriority = .required) -> Self {
        centerInSuperview(axis: axis)
    }
    
    @discardableResult
    func centerInView(_ anotherView: UIView,
                      withOffset offset: SBOffset,
                      priority: UILayoutPriority = .required) -> Self {
        centerInView(anotherView, axis: .horizontal, withOffset: offset.x, priority: priority)
        centerInView(anotherView, axis: .vertical, withOffset: offset.y, priority: priority)
        
        return self
    }
    
    @discardableResult
    func centerInSuperview(withOffset offset: SBOffset, priority: UILayoutPriority = .required) -> Self {
        guard let superview = superview else { return self }
        centerInView(superview, withOffset: offset, priority: priority)
        return self
    }
}

public extension UIView {
    
    @discardableResult
    func centerInView(_ anotherView: UIView,
                      axis: SBAxis,
                      withOffset offset: CGFloat = .zero,
                      priority: UILayoutPriority = .required) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        
        switch axis {
        case .x, .horizontal:
            let constraint = NSLayoutConstraint(item: self,
                                                attribute: .centerX,
                                                relatedBy: .equal,
                                                toItem: anotherView,
                                                attribute: .centerX,
                                                multiplier: 1.0, constant: offset
            )
            constraint.priority = priority
            constraint.isActive = true
            
        case .y, .vertical:
            let constraint = NSLayoutConstraint(item: self,
                                                attribute: .centerY,
                                                relatedBy: .equal,
                                                toItem: anotherView,
                                                attribute: .centerY,
                                                multiplier: 1.0, constant: offset
            )
            constraint.priority = priority
            constraint.isActive = true
        }
        return self
    }
    
    @discardableResult
    func centerInView(_ anotherView: UIView,
                      withOffset offset: UIOffset = .zero,
                      priority: UILayoutPriority = .required) -> Self {
        centerInView(anotherView, axis: .horizontal, withOffset: offset.horizontal, priority: priority)
        centerInView(anotherView, axis: .vertical, withOffset: offset.vertical, priority: priority)
        
        return self
    }
    
    @discardableResult
    func centerInSuperview(axis: SBAxis,
                           withOffset offset: CGFloat = .zero,
                           priority: UILayoutPriority = .required) -> Self {
        guard let superview = superview else { return self }
        centerInView(superview, axis: axis, withOffset: offset, priority: priority)
        return self
    }
    
    @discardableResult
    func centerInSuperview(withOffset offset: UIOffset = .zero, priority: UILayoutPriority = .required) -> Self {
        guard let superview = superview else { return self }
        centerInView(superview, withOffset: offset, priority: priority)
        return self
    }
}

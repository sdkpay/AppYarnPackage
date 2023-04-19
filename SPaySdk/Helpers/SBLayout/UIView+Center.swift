//
//  UIView+Center.swift
//  SPaySdk
//
//  Created by Арсений on 11.04.2023.
//

import UIKit

public extension UIView {
    
    /// Centers the axis of this view in its superview with the offset and priority
    /// of the constraint.
    ///
    /// To make Auto-Layout works properly, it automatically sets view property
    /// `translatesAutoresizingMaskIntoConstraints` to `false`
    ///
    /// - Precondition: The view should have the superview, otherwise this method
    /// will have no effect.
    ///
    /// - Parameter axis: Axis to center.
    /// - Parameter offset: Axis offset.
    /// - Parameter priority: The priority of the constraint.
    ///
    /// - Returns: `self` with attribute `@discardableResult`.
    ///
    @discardableResult
    func centerInSuperview(_ axis: SBAxis,
                           withOffset offset: CGFloat = .zero,
                           priority: UILayoutPriority = .required) -> Self {
        centerInSuperview(axis: axis)
    }
    
    /// Centers the axis of this view in another view with the offset and priority
    /// of the constraint.
    ///
    /// To make Auto-Layout works properly, it automatically sets view property
    /// `translatesAutoresizingMaskIntoConstraints` to `false`
    ///
    /// - Precondition: Another view must be in the same view hierarchy as this
    /// view.
    ///
    /// - Parameter anotherView: Another view to center in.
    /// - Parameter axis: Axis to center.
    /// - Parameter offset: Axis offset.
    /// - Parameter priority: The priority of the constraint.
    ///
    /// - Returns: `self` with attribute `@discardableResult`.
    @discardableResult
    func centerInView(_ anotherView: UIView,
                      withOffset offset: SBOffset,
                      priority: UILayoutPriority = .required) -> Self {
        centerInView(anotherView, axis: .horizontal, withOffset: offset.x, priority: priority)
        centerInView(anotherView, axis: .vertical, withOffset: offset.y, priority: priority)
        
        return self
    }
    
    /// Centers the view in its superview view with the offset and priority of the
    /// constraint.
    ///
    /// To make Auto-Layout works properly, it automatically sets view property
    /// `translatesAutoresizingMaskIntoConstraints` to `false`
    ///
    /// - Precondition: The view should have the superview, otherwise this method
    /// will have no effect.
    ///
    /// - Parameter offset: Axis offset.
    /// - Parameter priority: The priority of the constraint.
    ///
    /// - Returns: `self` with attribute `@discardableResult`.
    ///
    @discardableResult
    func centerInSuperview(withOffset offset: SBOffset, priority: UILayoutPriority = .required) -> Self {
        guard let superview = superview else { return self }
        centerInView(superview, withOffset: offset, priority: priority)
        return self
    }
}

public extension UIView {
    
    /// Centers the axis of this view in another view with the offset and priority
    /// of the constraint.
    ///
    /// To make Auto-Layout works properly, it automatically sets view property
    /// `translatesAutoresizingMaskIntoConstraints` to `false`
    ///
    /// - Precondition: Another view must be in the same view hierarchy as this
    /// view.
    ///
    /// - Parameter anotherView: Another view to center in.
    /// - Parameter axis: Axis to center.
    /// - Parameter offset: Axis offset.
    /// - Parameter priority: The priority of the constraint.
    ///
    /// - Returns: `self` with attribute `@discardableResult`.
    ///
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

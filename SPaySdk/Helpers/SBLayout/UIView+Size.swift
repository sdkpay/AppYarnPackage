//
//  UIView+Size.swift
//  SPaySdk
//
//  Created by Арсений on 11.04.2023.
//

import UIKit

public extension UIView {
    
    @discardableResult
    func width(to anotherView: UIView,
               withInset inset: CGFloat = .zero,
               usingRelation relation: NSLayoutConstraint.Relation = .equal,
               priority: UILayoutPriority = .required) -> Self {
        width(match: anotherView, withInset: inset, usingRelation: relation, priority: priority)
    }
    
    @discardableResult
    func height(to anotherView: UIView,
                withInset inset: CGFloat = .zero,
                usingRelation relation: NSLayoutConstraint.Relation = .equal,
                priority: UILayoutPriority = .required) -> Self {
        height(match: anotherView, withInset: inset, usingRelation: relation, priority: priority)
    }
    
    @discardableResult
    func size(to anotherView: UIView,
              withInsets insets: SBSizeInsets = .zero,
              usingRelation relation: NSLayoutConstraint.Relation = .equal,
              priority: UILayoutPriority = .required) -> Self {
        size(match: anotherView, withInsets: insets, usingRelation: relation, priority: priority)
    }
    
    @discardableResult
    func size(to anotherView: UIView,
              withInset inset: CGFloat = .zero,
              usingRelation relation: NSLayoutConstraint.Relation = .equal,
              priority: UILayoutPriority = .required) -> Self {
        size(match: anotherView, withInset: inset, usingRelation: relation, priority: priority)
    }
    
    @discardableResult
    func width(_ relation: NSLayoutConstraint.Relation,
               to width: CGFloat,
               priority: UILayoutPriority = .required) -> Self {
        self.width(width, usingRelation: relation, priority: priority)
        return self
    }
    
    @discardableResult
    func height(_ relation: NSLayoutConstraint.Relation,
                to height: CGFloat,
                priority: UILayoutPriority = .required) -> Self {
        self.height(height, usingRelation: relation, priority: priority)
        return self
    }
    
    @discardableResult
    func size(_ relation: NSLayoutConstraint.Relation,
              to size: CGSize,
              priority: UILayoutPriority = .required) -> Self {
        self.size(size, usingRelation: relation, priority: priority)
    }
    
    @discardableResult
    func size(_ relation: NSLayoutConstraint.Relation,
              toSquareWithSide side: CGFloat,
              priority: UILayoutPriority = .required) -> Self {
        size(toSquareWithSide: side, usingRelation: relation, priority: priority)
        return self
    }
}

public extension UIView {
    
    @discardableResult
    func width(_ width: CGFloat,
               usingRelation relation: NSLayoutConstraint.Relation = .equal,
               priority: UILayoutPriority = .required) -> Self {
        guard width != 0 else { return self }
        translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = NSLayoutConstraint(
            item: self, attribute: .width,
            relatedBy: relation,
            toItem: nil, attribute: .notAnAttribute,
            multiplier: 1.0, constant: width
        )
        constraint.priority = priority
        constraint.isActive = true
        
        return self
    }
    
    @discardableResult
    func height(_ height: CGFloat,
                usingRelation relation: NSLayoutConstraint.Relation = .equal,
                priority: UILayoutPriority = .required) -> Self {
        guard height != 0 else { return self }
        translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: .height,
            relatedBy: relation,
            toItem: nil, attribute: .notAnAttribute,
            multiplier: 1.0, constant: height
        )
        constraint.priority = priority
        constraint.isActive = true
        
        return self
    }
    
    @discardableResult
    func size(_ size: CGSize,
              usingRelation relation: NSLayoutConstraint.Relation = .equal,
              priority: UILayoutPriority = .required) -> Self {
        height(size.height, usingRelation: relation, priority: priority)
        width(size.width, usingRelation: relation, priority: priority)
        return self
    }
    
    @discardableResult
    func size(toSquareWithSide side: CGFloat,
              usingRelation relation: NSLayoutConstraint.Relation = .equal,
              priority: UILayoutPriority = .required) -> Self {
        size(CGSize(width: side, height: side), usingRelation: relation, priority: priority)
        return self
    }
}

public extension UIView {
    
    @discardableResult
    func width(match anotherView: UIView,
               withInset inset: CGFloat = .zero,
               usingRelation relation: NSLayoutConstraint.Relation = .equal,
               priority: UILayoutPriority = .required) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = NSLayoutConstraint(
            item: self, attribute: .width,
            relatedBy: relation,
            toItem: anotherView, attribute: .width,
            multiplier: 1.0, constant: -inset
        )
        constraint.priority = priority
        constraint.isActive = true
        
        return self
    }
    
    @discardableResult
    func height(match anotherView: UIView,
                withInset inset: CGFloat = .zero,
                usingRelation relation: NSLayoutConstraint.Relation = .equal,
                priority: UILayoutPriority = .required) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = NSLayoutConstraint(
            item: self, attribute: .height,
            relatedBy: relation,
            toItem: anotherView, attribute: .height,
            multiplier: 1.0, constant: -inset
        )
        constraint.priority = priority
        constraint.isActive = true
        
        return self
    }
    
    @discardableResult
    func size(match anotherView: UIView,
              withInsets insets: SBSizeInsets = .zero,
              usingRelation relation: NSLayoutConstraint.Relation = .equal,
              priority: UILayoutPriority = .required) -> Self {
        width(match: anotherView, withInset: insets.horizontal, usingRelation: relation, priority: priority)
        height(match: anotherView, withInset: insets.vertical, usingRelation: relation, priority: priority)
        
        return self
    }
    
    @discardableResult
    func size(match anotherView: UIView,
              withInset inset: CGFloat,
              usingRelation relation: NSLayoutConstraint.Relation = .equal,
              priority: UILayoutPriority = .required) -> Self {
        size(
            match: anotherView,
            withInsets: SBSizeInsets(horizontal: inset, vertical: inset),
            usingRelation: relation,
            priority: priority
        )
    }
}

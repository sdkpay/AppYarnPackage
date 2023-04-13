//
//  UIView+Touch.swift
//  SPaySdk
//
//  Created by Арсений on 11.04.2023.
//

import UIKit

public extension UIView {
    @discardableResult
    func touch(topTo top: NSLayoutYAxisAnchor? = nil,
               leftTo left: NSLayoutXAxisAnchor? = nil,
               bottomTo bottom: NSLayoutYAxisAnchor? = nil,
               rightTo right: NSLayoutXAxisAnchor? = nil,
               withInsets insets: UIEdgeInsets = .zero,
               priority: UILayoutPriority = .required) -> Self {
        guard top != nil || left != nil || bottom != nil || right != nil else { return self }
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            let constraint = topAnchor.constraint(equalTo: top, constant: insets.top)
            constraint.priority = priority
            constraint.isActive = true
        }
        
        if let left = left {
            let constraint = leftAnchor.constraint(equalTo: left, constant: insets.left)
            constraint.priority = priority
            constraint.isActive = true
        }
        
        if let bottom = bottom {
            let constraint = bottomAnchor.constraint(equalTo: bottom, constant: -insets.bottom)
            constraint.priority = priority
            constraint.isActive = true
        }
        
        if let right = right {
            let constaint = rightAnchor.constraint(equalTo: right, constant: -insets.right)
            constaint.priority = priority
            constaint.isActive = true
        }
        
        return self
    }
    
    @discardableResult
    func touchEdge(_ edge: SBEdge,
                   toEdge pinningEdge: SBEdge,
                   ofView anotherView: UIView,
                   withInset inset: CGFloat = .zero,
                   usingRelation relation: NSLayoutConstraint.Relation = .equal,
                   priority: UILayoutPriority = .required) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = NSLayoutConstraint(
            item: self, attribute: edge.convertedToNSLayoutAttribute,
            relatedBy: relation,
            toItem: anotherView, attribute: pinningEdge.convertedToNSLayoutAttribute,
            multiplier: 1.0,
            constant: inset * edge.directionalMultiplier
        )
        constraint.priority = priority
        constraint.isActive = true
        
        return self
    }
    
    @discardableResult
    func touchEdge(_ edge: SBEdge,
                   toSameEdgeOfView anotherView: UIView,
                   withInset inset: CGFloat = .zero,
                   usingRelation relation: NSLayoutConstraint.Relation = .equal,
                   priority: UILayoutPriority = .required) -> Self {
        touchEdge(edge,
                  toEdge: edge, ofView: anotherView,
                  withInset: inset,
                  usingRelation: relation,
                  priority: priority
        )
    }
    
    @discardableResult
    func touchEdges(_ edges: [SBEdge] = SBEdge.all,
                    toSameEdgesOfView anotherView: UIView,
                    withInsets insets: UIEdgeInsets = .zero,
                    usingRelation relation: NSLayoutConstraint.Relation = .equal,
                    priority: UILayoutPriority = .required) -> Self {
        for edge in edges {
            switch edge {
            case .left:
                touchEdge(.left,
                          toSameEdgeOfView: anotherView,
                          withInset: insets.left,
                          usingRelation: relation,
                          priority: priority
                )
            case .right:
                touchEdge(.right,
                          toSameEdgeOfView: anotherView,
                          withInset: insets.right,
                          usingRelation: relation,
                          priority: priority
                )
            case .top:
                touchEdge(.top,
                          toSameEdgeOfView: anotherView,
                          withInset: insets.top,
                          usingRelation: relation,
                          priority: priority
                )
            case .bottom:
                touchEdge(.bottom,
                          toSameEdgeOfView: anotherView,
                          withInset: insets.bottom,
                          usingRelation: relation,
                          priority: priority
                )
            }
        }
        return self
    }
    
    @discardableResult
    func touchEdges(_ edges: [SBEdge] = SBEdge.all,
                    toSameEdgesOfView anotherView: UIView,
                    withInset inset: CGFloat,
                    usingRelation relation: NSLayoutConstraint.Relation = .equal,
                    priority: UILayoutPriority = .required) -> Self {
        touchEdges(edges,
                   toSameEdgesOfView: anotherView,
                   withInsets: UIEdgeInsets(inset: inset),
                   usingRelation: relation,
                   priority: priority
        )
    }
    
    @discardableResult
    func touchEdges(ofGroup edgeGroup: SBEdgeGroup,
                    toSameEdgesOfView anotherView: UIView,
                    withInset inset: CGFloat,
                    usingRelation relation: NSLayoutConstraint.Relation = .equal,
                    priority: UILayoutPriority = .required) -> Self {
        touchEdges(edgeGroup.edges,
                   toSameEdgesOfView: anotherView,
                   withInset: inset,
                   usingRelation: relation,
                   priority: priority
        )
    }
    
    @discardableResult
    func touchEdges(toSameEdgesOfView anotherView: UIView,
                    excludingEdge excludedEdge: SBEdge,
                    withInsets insets: UIEdgeInsets = .zero,
                    usingRelation relation: NSLayoutConstraint.Relation = .equal,
                    priority: UILayoutPriority = .required) -> Self {
        let edges = SBEdge.all.filter { $0 != excludedEdge }
        touchEdges(edges,
                   toSameEdgesOfView: anotherView,
                   withInsets: insets,
                   usingRelation: relation,
                   priority: priority
        )
        return self
    }
    
    @discardableResult
    func touchEdges(toSameEdgesOfView anotherView: UIView,
                    excludingEdge excludedEdge: SBEdge,
                    withInset inset: CGFloat,
                    usingRelation relation: NSLayoutConstraint.Relation = .equal,
                    priority: UILayoutPriority = .required) -> Self {
        touchEdges(
            toSameEdgesOfView: anotherView,
            excludingEdge: excludedEdge,
            withInsets: UIEdgeInsets(inset: inset),
            usingRelation: relation, priority: priority
        )
    }
    
    @discardableResult
    func touchEdge(_ edge: SBEdge,
                   toEdge pinningEdge: SBEdge,
                   ofGuide guide: SBGuide,
                   withInset inset: CGFloat = .zero,
                   usingRelation relation: NSLayoutConstraint.Relation = .equal,
                   priority: UILayoutPriority = .required) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        
        let layoutGuide = guide.layoutGuide
        let constraint = NSLayoutConstraint(
            item: self, attribute: edge.convertedToNSLayoutAttribute,
            relatedBy: relation,
            toItem: layoutGuide,
            attribute: pinningEdge.convertedToNSLayoutAttribute,
            multiplier: 1.0,
            constant: inset * edge.directionalMultiplier
        )
        constraint.priority = priority
        constraint.isActive = true
        
        return self
    }
    
    @discardableResult
    func touchEdge(_ edge: SBEdge,
                   toSameEdgeOfGuide guide: SBGuide,
                   withInset inset: CGFloat = .zero,
                   usingRelation relation: NSLayoutConstraint.Relation = .equal,
                   priority: UILayoutPriority = .required) -> Self {
        touchEdge(edge,
                  toEdge: edge,
                  ofGuide: guide,
                  withInset: inset,
                  usingRelation: relation,
                  priority: priority
        )
    }
    
    @discardableResult
    func touchEdges(_ edges: [SBEdge] = SBEdge.all,
                    toSameEdgesOfGuide guide: SBGuide,
                    withInsets insets: UIEdgeInsets = .zero,
                    usingRelation relation: NSLayoutConstraint.Relation = .equal,
                    priority: UILayoutPriority = .required) -> Self {
        for edge in edges {
            switch edge {
            case .left:
                touchEdge(.left,
                          toSameEdgeOfGuide: guide,
                          withInset: insets.left,
                          usingRelation: relation,
                          priority: priority
                )
            case .right:
                touchEdge(.right,
                          toSameEdgeOfGuide: guide,
                          withInset: insets.right,
                          usingRelation: relation,
                          priority: priority
                )
            case .top:
                touchEdge(.top,
                          toSameEdgeOfGuide: guide,
                          withInset: insets.top,
                          usingRelation: relation,
                          priority: priority
                )
            case .bottom:
                touchEdge(.bottom,
                          toSameEdgeOfGuide: guide,
                          withInset: insets.bottom,
                          usingRelation: relation,
                          priority: priority
                )
            }
        }
        return self
    }
    
    @discardableResult
    func touchEdges(_ edges: [SBEdge] = SBEdge.all,
                    toSameEdgesOfGuide guide: SBGuide,
                    withInset inset: CGFloat,
                    usingRelation relation: NSLayoutConstraint.Relation = .equal,
                    priority: UILayoutPriority = .required) -> Self {
        touchEdges(edges,
                   toSameEdgesOfGuide: guide,
                   withInsets: UIEdgeInsets(inset: inset),
                   usingRelation: relation,
                   priority: priority
        )
    }
    
    @discardableResult
    func touchEdges(ofGroup edgeGroup: SBEdgeGroup,
                    toSameEdgesOfGuide guide: SBGuide,
                    withInset inset: CGFloat,
                    usingRelation relation: NSLayoutConstraint.Relation = .equal,
                    priority: UILayoutPriority = .required) -> Self {
        touchEdges(edgeGroup.edges,
                   toSameEdgesOfGuide: guide,
                   withInset: inset,
                   usingRelation: relation,
                   priority: priority
        )
    }
    
    @discardableResult
    func touchEdges(toSameEdgesOfGuide guide: SBGuide,
                    excludingEdge excludedEdge: SBEdge,
                    withInsets insets: UIEdgeInsets = .zero,
                    usingRelation relation: NSLayoutConstraint.Relation = .equal,
                    priority: UILayoutPriority = .required) -> Self {
        let edges = SBEdge.all.filter { $0 != excludedEdge }
        touchEdges(edges,
                   toSameEdgesOfGuide: guide,
                   withInsets: insets,
                   usingRelation: relation,
                   priority: priority
        )
        return self
    }
    
    @discardableResult
    func touchEdges(toSameEdgesOfGuide guide: SBGuide,
                    excludingEdge excludedEdge: SBEdge,
                    withInset inset: CGFloat,
                    usingRelation relation: NSLayoutConstraint.Relation = .equal,
                    priority: UILayoutPriority = .required) -> Self {
        touchEdges(
            toSameEdgesOfGuide: guide,
            excludingEdge: excludedEdge,
            withInsets: UIEdgeInsets(inset: inset),
            usingRelation: relation, priority: priority
        )
    }
}

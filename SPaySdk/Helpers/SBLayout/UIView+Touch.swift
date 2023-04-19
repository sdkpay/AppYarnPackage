//
//  UIView+Touch.swift
//  SPaySdk
//
//  Created by Арсений on 11.04.2023.
//

import UIKit

public extension UIView {
    /// Touches the edges to the given `NSLayoutAxisAnchor`s with the insets and
    /// priority of the constraints.
    ///
    /// 1. Compact version of default Swift layout. Allows you to pin edges to
    /// specific `NSLayoutAxisAnchor`.
    ///
    /// 2. To make Auto-Layout works properly, it automatically sets view
    /// property `translatesAutoresizingMaskIntoConstraints` to `false`
    ///
    /// - Precondition: You should pass at least one anchor, otherwise this method
    /// will have no effect.
    ///
    /// - Parameter top: The anchor to pin top to.
    /// - Parameter left: The anchor to pin left to.
    /// - Parameter bottom: The anchor to pin bottom to.
    /// - Parameter right: The anchor to pin right to.
    /// - Parameter insets: The insets between the edges.
    /// - Parameter priority: The priority of the constraints.
    ///
    /// - Returns: `self` with attribute `@discardableResult`.
    ///
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
    /// Touches the edge of the view using the specified type of relation to the
    /// given edge of another view with the inset and priority of the constraint.
    ///
    /// 1. Consider, accordingly to
    /// [Apple's documentation](https://apple.co/2PFH9f2), you cannot pin edges
    /// with different axis, otherwise it will throw fatal error.
    ///
    /// 2. To make Auto-Layout works properly, it automatically sets view
    /// property `translatesAutoresizingMaskIntoConstraints` to `false`
    ///
    /// - Precondition:
    ///     - Another view must be in the same view hierarchy as this view.
    ///     - Pin edges with same axis or method will throw fatal error.
    ///
    /// - Parameter edge: The edge of this view to pin.
    /// - Parameter pinningEdge: The edge of another view to pin to.
    /// - Parameter anotherView: Another view to pin to.
    /// - Parameter inset: The inset between the edge of this view and the edge of
    /// another view.
    /// - Parameter relation: The type of relationship for the constraint.
    /// - Parameter priority: The priority of the constraint.
    ///
    /// - Returns: `self` with attribute `@discardableResult`.
    ///
    @discardableResult
    func touchEdge(_ edge: SBEdge,
                   toEdge pinningEdge: SBEdge,
                   ofView anotherView: UIView,
                   withInset inset: CGFloat = .zero,
                   usingRelation relation: NSLayoutConstraint.Relation = .equal,
                   priority: UILayoutPriority = .required) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: edge.convertedToNSLayoutAttribute,
            relatedBy: relation,
            toItem: anotherView,
            attribute: pinningEdge.convertedToNSLayoutAttribute,
            multiplier: 1.0,
            constant: inset * edge.directionalMultiplier
        )
        constraint.priority = priority
        constraint.isActive = true
        
        return self
    }
    /// Touches the given edge of the view using the specified type of relation to
    /// the corresponding margin of another view with the inset and priority of
    /// the constraint.
    ///
    /// To make Auto-Layout works properly, it automatically sets view property
    /// `translatesAutoresizingMaskIntoConstraints` to `false`.
    ///
    /// - Precondition: Another view must be in the same view hierarchy as this
    /// view.
    ///
    /// - Parameter edge: The edge of this view to pin to.
    /// - Parameter anotherView: Another view to pin to.
    /// - Parameter inset: The inset beetween the edge of this view and the
    /// corresponding edge of another view.
    /// - Parameter relation: The type of relationship for the constraint.
    /// - Parameter priority: The priority of the constraint.
    ///
    /// - Returns: `self` with attribute `@discardableResult`.
    ///
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
    /// Touches the given edges of the view using the specified type of relation to
    /// the corresponding margins of another view with the insets and priority of
    /// the constraints.
    ///
    /// To make Auto-Layout works properly, it automatically sets view
    /// property `translatesAutoresizingMaskIntoConstraints` to `false`.
    ///
    /// - Precondition: Another view must be in the same view hierarchy as this
    /// view.
    ///
    /// - Parameter edges: The edges of this view to pin to.
    /// - Parameter anotherView: Another view to pin to.
    /// - Parameter insets: The insets beetween the edges of this view and
    /// corresponding edges of another view.
    /// - Parameter relation: The type of relationship for the constraints.
    /// - Parameter priority: The priority of the constraint.
    ///
    /// - Tag: toSameEdgesOfView_insets
    ///
    /// - Returns: `self` with attribute `@discardableResult`.
    ///
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
    /// Pins the given edges of the view using the specified type of relation to
    /// the corresponding margins of another view with the equal insets and
    /// priority of the constraints.
    ///
    /// To make Auto-Layout works properly, it automatically sets view
    /// property`translatesAutoresizingMaskIntoConstraints` to `false`.
    ///
    /// - Precondition: Another view must be in the same view hierarchy as this
    /// view.
    ///
    /// - Parameter edges: The edges of this view to pin to.
    /// - Parameter anotherView: Another view to pin to.
    /// - Parameter inset: The inset beetween the edges of this view and
    /// corresponding edges of another view.
    /// - Parameter relation: The type of relationship for the constraints.
    /// - Parameter priority: The priority of the constraint.
    ///
    /// - Tag: toSameEdgesOfView_inset
    ///
    /// - Returns: `self` with attribute `@discardableResult`.
    ///
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
    /// Touches edges of the view of the given group using the specified type of
    /// relation to the corresponding margins of another view with the equal
    /// insets and priority of the constraints.
    ///
    /// To make Auto-Layout works properly, it automatically sets view property
    /// `translatesAutoresizingMaskIntoConstraints` to `false`.
    ///
    /// - Precondition: Another view must be in the same view hierarchy as this
    /// view.
    ///
    /// - Parameter edgeGroup: The group of edges of this view to pin to.
    /// - Parameter anotherView: Another view to pin to.
    /// - Parameter inset: The inset beetween the edges of this view and
    /// corresponding edges of another view.
    /// - Parameter relation: The type of relationship for the constraints.
    /// - Parameter priority: The priority of the constraint.
    ///
    /// - Returns: `self` with attribute `@discardableResult`.
    ///
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
    /// Touches the edges of the view using the specified type of relation to the
    /// corresponding margins of another view with the insets and priority of the
    /// constraints, excluding one edge.
    ///
    /// To make Auto-Layout works properly, it automatically sets view
    /// property `translatesAutoresizingMaskIntoConstraints` to `false`.
    ///
    /// - Precondition: Another view must be in the same view hierarchy as this
    /// view.
    ///
    /// - Parameter anotherView: Another view to pin to.
    /// - Parameter excludedEdge: The edge to be ingored and not pinned.
    /// - Parameter insets: The insets beetween the edges of this view and
    /// corresponding edges of another view.
    /// - Parameter relation: The type of relationship for the constraints.
    /// - Parameter priority: The priority of the constraint.
    ///
    /// - Returns: `self` with attribute `@discardableResult`.
    ///
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
    /// Touches the edges of the view using the specified type of relation to the
    /// corresponding margins of another view with the equal inset and priority of
    /// the constraints, excluding one edge.
    ///
    /// 2. To make Auto-Layout works properly, it automatically sets view
    /// property `translatesAutoresizingMaskIntoConstraints` to `false`.
    ///
    /// - Precondition: Another view must be in the same view hierarchy as this
    /// view.
    ///
    /// - Parameter anotherView: Another view to pin to.
    /// - Parameter excludedEdge: The edge to be ingored and not pinned.
    /// - Parameter inset: The inset beetween the edges of this view and
    /// corresponding edges of another view.
    /// - Parameter relation: The type of relationship for the constraints.
    /// - Parameter priority: The priority of the constraint.
    ///
    /// - Returns: `self` with attribute `@discardableResult`.
    ///
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
    /// Touches the edge of the view using the specified type of relation to the
    /// given edge of guide with the inset and priority of the constraint.
    ///
    /// 1. Consider, accordingly to
    /// [Apple's documentation](https://apple.co/2PFH9f2), you cannot pin edges
    /// with different axis, otherwise it will throw fatal error.
    ///
    /// 2. To make Auto-Layout works properly, it automatically sets view
    /// property `translatesAutoresizingMaskIntoConstraints` to `false`
    ///
    /// - Precondition: Pin edges with same axis or method will throw fatal error.
    ///
    /// - Parameter edge: The edge of this view to pin.
    /// - Parameter pinningEdge: The edge of another view to pin to.
    /// - Parameter guide: The guide to pin to.
    /// - Parameter inset: The inset between the edge of this view and the edge of
    /// guide.
    /// - Parameter relation: The type of relationship for the constraint.
    /// - Parameter priority: The priority of the constraint.
    ///
    /// - Returns: `self` with attribute `@discardableResult`.
    ///
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
    /// Touches the given edge of the view using the specified type of relation to
    /// the corresponding margin of guide with the inset and priority of
    /// the constraint.
    ///
    /// To make Auto-Layout works properly, it automatically sets view property
    /// `translatesAutoresizingMaskIntoConstraints` to `false`.
    ///
    /// - Parameter edge: The edge of this view to pin to.
    /// - Parameter guide: The guide to pin to.
    /// - Parameter inset: The inset beetween the edge of this view and the
    /// corresponding edge of guide.
    /// - Parameter relation: The type of relationship for the constraint.
    /// - Parameter priority: The priority of the constraint.
    ///
    /// - Returns: `self` with attribute `@discardableResult`.
    ///
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
    /// Pins the given edges of the view using the specified type of relation to
    /// the corresponding margins of guide with the insets and priority of
    /// the constraints.
    ///
    /// To make Auto-Layout works properly, it automatically sets view
    /// property `translatesAutoresizingMaskIntoConstraints` to `false`.
    ///
    /// - Parameter edges: The edges of this view to pin to.
    /// - Parameter guide: The guide to pin to.
    /// - Parameter insets: The insets beetween the edges of this view and
    /// corresponding edges of guide.
    /// - Parameter relation: The type of relationship for the constraints.
    /// - Parameter priority: The priority of the constraint.
    ///
    /// - Returns: `self` with attribute `@discardableResult`.
    ///
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
    /// Pins the given edges of the view using the specified type of relation to
    /// the corresponding margins of guide with the equal insets and
    /// priority of the constraints.
    ///
    /// To make Auto-Layout works properly, it automatically sets view
    /// property`translatesAutoresizingMaskIntoConstraints` to `false`.
    ///
    /// - Parameter edges: The edges of this view to pin to.
    /// - Parameter guide: The guide to pin to.
    /// - Parameter inset: The inset beetween the edges of this view and
    /// corresponding edges of guide.
    /// - Parameter relation: The type of relationship for the constraints.
    /// - Parameter priority: The priority of the constraint.
    ///
    /// - Returns: `self` with attribute `@discardableResult`.
    ///
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
    /// Touches edges of the view of the given group using the specified type of
    /// relation to the corresponding margins of guide with the equal
    /// insets and priority of the constraints.
    ///
    /// To make Auto-Layout works properly, it automatically sets view property
    /// `translatesAutoresizingMaskIntoConstraints` to `false`.
    ///
    /// - Parameter edgeGroup: The group of edges of this view to pin to.
    /// - Parameter guide: The guide to pin to.
    /// - Parameter inset: The inset beetween the edges of this view and
    /// corresponding edges of guide.
    /// - Parameter relation: The type of relationship for the constraints.
    /// - Parameter priority: The priority of the constraint.
    ///
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
    /// Touches the edges of the view using the specified type of relation to the
    /// corresponding margins of guide with the insets and priority of the
    /// constraints, excluding one edge.
    ///
    /// To make Auto-Layout works properly, it automatically sets view
    /// property `translatesAutoresizingMaskIntoConstraints` to `false`.
    ///
    /// - Parameter guide: The guide to pin to.
    /// - Parameter excludedEdge: The edge to be ingored and not pinned.
    /// - Parameter insets: The insets beetween the edges of this view and
    /// corresponding edges of guide.
    /// - Parameter relation: The type of relationship for the constraints.
    /// - Parameter priority: The priority of the constraint.
    ///
    /// - Returns: `self` with attribute `@discardableResult`.
    ///
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
    /// Touches the edges of the view using the specified type of relation to the
    /// corresponding margins of guide with the equal inset and priority of
    /// the constraints, excluding one edge.
    ///
    /// To make Auto-Layout works properly, it automatically sets view
    /// property `translatesAutoresizingMaskIntoConstraints` to `false`.
    ///
    /// - Parameter guide: The guide to pin to.
    /// - Parameter excludedEdge: The edge to be ingored and not pinned.
    /// - Parameter inset: The inset beetween the edges of this view and
    /// corresponding edges of guide.
    /// - Parameter relation: The type of relationship for the constraints.
    /// - Parameter priority: The priority of the constraint.
    ///
    /// - Returns: `self` with attribute `@discardableResult`.
    ///
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

//
//  UIView+TouchEdge.swift
//  SPaySdk
//
//  Created by Арсений on 11.04.2023.
//

import UIKit

extension UIView {
    /// Touches the edge of the view using the specified type of relation to the
    /// given edge of its superview with the inset and priority of the constraint.
    /// Optionally respects one of pre-defined Apple's layout guides.
    ///
    /// Consider, accordingly to
    /// [Apple's documentation](https://apple.co/2PFH9f2), you cannot touch edges
    /// with different axis, otherwise it will throw fatal error.
    ///
    /// To make Auto-Layout works properly, it automatically sets view
    /// property `translatesAutoresizingMaskIntoConstraints` to `false`.
    ///
    /// - Precondition:
    ///     - The view should have the superview, otherwise method will have no
    ///     effect.
    ///     - Pin edges with same axis or method will throw fatal error.
    ///
    /// - Parameter edge: The edge of this view to pin.
    /// - Parameter superviewEdge: The edge of its superview to pin to.
    /// - Parameter inset: The inset between the edge of this view and the edge of
    /// its superview.
    /// - Parameter guide: The guide to respect in layout.
    /// - Parameter relation: The type of relationship for constraint.
    /// - Parameter priority: The priority of the constraint.
    ///
    /// - Returns: `self` with attribute `@discardableResult`.
    ///
    
    @discardableResult
    func touchEdge(_ edge: SBEdge,
                   toSuperviewEdge superviewEdge: SBEdge,
                   withInset inset: CGFloat = .zero,
                   respectingGuide guide: SBSuperviewGuide = .none,
                   usingRelation relation: NSLayoutConstraint.Relation = .equal,
                   priority: UILayoutPriority = .required) -> Self {
        guard let superview = superview else {
            assertionFailure("Expected superview but found nil when attempting to make constraint.")
            return self
        }
        
        switch guide {
        case .none:
            touchEdge(edge,
                      toEdge: superviewEdge,
                      ofView: superview,
                      withInset: inset,
                      usingRelation: relation,
                      priority: priority
            )
        default:
            let guide = guide.convertedToESLGuide(superview: superview)!
            touchEdge(edge,
                      toEdge: superviewEdge,
                      ofGuide: guide,
                      withInset: inset,
                      usingRelation: relation,
                      priority: priority
            )
        }
        return self
    }
    /// Touches the given edge of the view using the specified type of relation to
    /// the corresponding margin of its superview with the inset and priority of
    /// the constraint. Optionally respects one of pre-defined Apple's layout
    /// guides.
    ///
    /// To make Auto-Layout works properly, it automatically sets view property
    /// `translatesAutoresizingMaskIntoConstraints` to `false`.
    ///
    /// - Precondition: The view should have the superview, otherwise this method
    /// will have no effect.
    ///
    /// - Parameter edge: The edge of this view to pin.
    /// - Parameter inset: The inset beetween the edge of this view and the
    /// corresponding edge of its superview.
    /// - Parameter guide: The guide to respect in layout.
    /// - Parameter relation: The type of relationship for constraint.
    /// - Parameter priority: The priority of the constraint.
    ///
    /// - Returns: `self` with attribute `@discardableResult`.
    ///
    @discardableResult
    func touchEdgeToSuperview(_ edge: SBEdge,
                              withInset inset: CGFloat = .zero,
                              respectingGuide guide: SBSuperviewGuide = .none,
                              usingRelation relation: NSLayoutConstraint.Relation = .equal,
                              priority: UILayoutPriority = .required) -> Self {
        guard let superview = superview else {
            assertionFailure("Expected superview but found nil when attempting to make constraint.")
            return self
        }
        
        switch guide {
        case .none:
            touchEdge(edge,
                      toSameEdgeOfView: superview,
                      withInset: inset,
                      usingRelation: relation,
                      priority: priority
            )
        default:
            let guide = guide.convertedToESLGuide(superview: superview)!
            touchEdge(edge,
                      toSameEdgeOfGuide: guide,
                      withInset: inset,
                      usingRelation: relation,
                      priority: priority
            )
        }
        return self
    }
    /// Touches the given edges of the view using the specified type of relation to
    /// the corresponding margins of its superview with the insets and priority of
    /// the constraints. Optionally respects one of pre-defined Apple's layout
    /// guides.
    ///
    ///
    /// To make Auto-Layout works properly, it automatically sets view property
    /// `translatesAutoresizingMaskIntoConstraints` to `false`.
    ///
    /// - Precondition: The view should have the superview, otherwise this method
    /// will have no effect.
    ///
    /// - Parameter edges: The edges of this view to pin.
    /// - Parameter insets: The insets beetween the edges of this view and the
    /// corresponding edges of its superview.
    /// - Parameter guide: The guide to respect in layout.
    /// - Parameter relation: The type of relationship for constraint.
    /// - Parameter priority: The priority of the constraint.
    ///
    /// - Returns: `self` with attribute `@discardableResult`.
    ///
    @discardableResult
    func touchEdgesToSuperview(_ edges: [SBEdge] = SBEdge.all,
                               withInsets insets: UIEdgeInsets = .zero,
                               respectingGuide guide: SBSuperviewGuide = .none,
                               usingRelation relation: NSLayoutConstraint.Relation = .equal,
                               priority: UILayoutPriority = .required) -> Self {
        guard let superview = superview else {
            assertionFailure("Expected superview but found nil when attempting to make constraint.")
            return self
        }
        
        switch guide {
        case .none:
            touchEdges(edges,
                       toSameEdgesOfView: superview,
                       withInsets: insets,
                       usingRelation: relation,
                       priority: priority
            )
        default:
            let guide = guide.convertedToESLGuide(superview: superview)!
            touchEdges(edges,
                       toSameEdgesOfGuide: guide,
                       withInsets: insets,
                       usingRelation: relation,
                       priority: priority
            )
        }
        return self
    }
    /// Touches the given edges of the view using the specified type of relation to
    /// the corresponding margins of its superview with the equal insets and
    /// priority of the constraints. Optionally respects one of pre-defined Apple's
    /// layout guides.
    ///
    /// To make Auto-Layout works properly, it automatically sets view
    /// property `translatesAutoresizingMaskIntoConstraints` to `false`.
    ///
    /// - Precondition: The view should have the superview, otherwise this method
    /// will have no effect.
    ///
    /// - Parameter edges: The edges of this view to pin.
    /// - Parameter inset: The inset beetween the edges of this view and the
    /// corresponding edges of its superview.
    /// - Parameter guide: The guide to respect in layout.
    /// - Parameter relation: The type of relationship for constraint.
    /// - Parameter priority: The priority of the constraint.
    ///
    /// - Returns: `self` with attribute `@discardableResult`.
    ///
    @discardableResult
    func pinEdgesToSuperview(_ edges: [SBEdge] = SBEdge.all,
                             withInset inset: CGFloat,
                             respectingGuide guide: SBSuperviewGuide = .none,
                             usingRelation relation: NSLayoutConstraint.Relation = .equal,
                             priority: UILayoutPriority = .required) -> Self {
        touchEdgesToSuperview(edges,
                              withInsets: UIEdgeInsets(inset: inset),
                              respectingGuide: guide,
                              usingRelation: relation,
                              priority: priority
        )
    }
    /// Touches edges of the view of the given group using the specified type of
    /// relation to the corresponding margins of its superview with the equal
    /// insets and priority of the constraints. Optionally respects one of
    /// pre-defined Apple's layout guides.
    ///
    /// To make Auto-Layout works properly, it automatically sets view property
    /// `translatesAutoresizingMaskIntoConstraints` to `false`.
    ///
    /// - Precondition: The view should have the superview, otherwise this method
    /// will have no effect.
    ///
    /// - Parameter group: The group of edges of this view to pin to.
    /// - Parameter inset: The inset beetween the edges of this view and
    /// corresponding edges of its superview.
    /// - Parameter guide: The guide to respect in layout.
    /// - Parameter relation: The type of relationship for the constraints.
    /// - Parameter priority: The priority of the constraint.
    ///
    /// - Returns: `self` with attribute `@discardableResult`.
    ///
    @discardableResult
    func touchEdgesToSuperview(ofGroup group: SBEdgeGroup,
                               withInset inset: CGFloat = .zero,
                               respectingGuide guide: SBSuperviewGuide = .none,
                               usingRelation relation: NSLayoutConstraint.Relation = .equal,
                               priority: UILayoutPriority = .required) -> Self {
        pinEdgesToSuperview(group.edges,
                            withInset: inset,
                            respectingGuide: guide,
                            usingRelation: relation,
                            priority: priority
        )
    }
    /// Touches the edges of the view using the specified type of relation to the
    /// corresponding margins of its superview with the insets and priority of the
    /// constraints, excluding one edge. Optionally respects one of pre-defined
    /// Apple's layout guides.
    ///
    /// To make Auto-Layout works properly, it automatically sets view
    /// property `translatesAutoresizingMaskIntoConstraints` to `false`
    ///
    /// - Precondition: The view should have the superview, otherwise this method
    /// will have no effect.
    ///
    /// - Parameter excludedEdge: The edge to be ingored and not pinned.
    /// - Parameter insets: The insets beetween the edges of this view and
    /// corresponding edges of another view.
    /// - Parameter guide: The guide to respect in layout.
    /// - Parameter relation: The type of relationship for the constraints.
    /// - Parameter priority: The priority of the constraint.
    ///
    /// - Returns: `self` with attribute `@discardableResult`.
    ///
    @discardableResult
    func touchEdgesToSuperview(excludingEdge excludedEdge: SBEdge,
                               withInsets insets: UIEdgeInsets = .zero,
                               respectingGuide guide: SBSuperviewGuide = .none,
                               usingRelation relation: NSLayoutConstraint.Relation = .equal,
                               priority: UILayoutPriority = .required) -> Self {
        let edges = SBEdge.all.filter { $0 != excludedEdge }
        touchEdgesToSuperview(edges,
                              withInsets: insets,
                              respectingGuide: guide,
                              usingRelation: relation,
                              priority: priority
        )
        return self
    }
    /// Touches the edges of the view using the specified type of relation to the
    /// corresponding margins of its superview with the equal inset and priority
    /// of the constraints, excluding one edge. Optionally respects one of
    /// pre-defined Apple's layout guides.
    ///
    /// To make Auto-Layout works properly, it automatically sets view
    /// property `translatesAutoresizingMaskIntoConstraints` to `false`
    ///
    /// - Precondition: The view should have the superview, otherwise this method
    /// will have no effect.
    ///
    /// - Parameter excludedEdge: The edge to be ingored and not pinned.
    /// - Parameter inset: The inset beetween the edges of this view and
    /// corresponding edges of its superview.
    /// - Parameter guide: The guide to respect in layout.
    /// - Parameter relation: The type of relationship for the constraints.
    /// - Parameter priority: The priority of the constraint.
    ///
    /// - Returns: `self` with attribute `@discardableResult`.
    ///
    @discardableResult
    func touchEdgesToSuperview(excludingEdge excludedEdge: SBEdge,
                               withInset inset: CGFloat,
                               respectingGuide guide: SBSuperviewGuide = .none,
                               usingRelation relation: NSLayoutConstraint.Relation = .equal,
                               priority: UILayoutPriority = .required) -> Self {
        touchEdgesToSuperview(
            excludingEdge: excludedEdge,
            withInsets: UIEdgeInsets(inset: inset),
            respectingGuide: guide,
            usingRelation: relation,
            priority: priority
        )
    }
}

//
//  UIView+TouchEdge.swift
//  SPaySdk
//
//  Created by Арсений on 11.04.2023.
//

import UIKit

public extension UIView {
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

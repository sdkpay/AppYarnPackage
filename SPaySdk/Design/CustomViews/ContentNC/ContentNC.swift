//
//  ContentNC.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 28.12.2022.
//

import UIKit
import Lottie

private extension TimeInterval {
    static let animationDuration: TimeInterval = 0.35
}

final class ContentNC: UIViewController {
    
    private lazy var backgroundView: UIImageView = {
        // DEBUG
        let view = UIImageView(image: Asset.background.image)
        view.contentMode = .scaleAspectFill
        view.tag = .backgroundViewTag
        return view
    }()
    
    var topViewController: UIViewController? {
        viewControllers.last
    }
    
    private lazy var customTransitioningDelegate = CoverTransitioningDelegate()
    private(set) var viewControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addBackground()
    }

    convenience init(rootViewController: UIViewController) {
        self.init()
        setRootViewController(rootViewController)
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        transitioningDelegate = customTransitioningDelegate
        modalPresentationStyle = .custom
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @MainActor
    func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        guard let to = viewControllers.last else {
            return
        }

        if let from = topViewController {
            transition(from: from, to: to, animated: animated)
        } else {
            setRootViewController(to)
        }
        self.viewControllers = viewControllers
    }

    @MainActor
    func pushViewController(_ viewController: ContentVC, animated: Bool) {
        guard let from = topViewController else {
            setRootViewController(viewController)
            return
        }
        transition(from: from, to: viewController, animated: animated)
        self.viewControllers.append(viewController)
    }

    @MainActor
    @discardableResult
    func popViewController(animated: Bool, completion: Action? = nil) -> UIViewController? {
        guard let from = topViewController, from != viewControllers.first else { return nil }

        viewControllers.removeLast()
        if let to = topViewController {
            transition(from: from, to: to, animated: animated, completion: completion)
        }
        return from
    }
    
    private func addBackground() {
        backgroundView.alpha = 0
        self.backgroundView
            .add(toSuperview: self.view)
            .touchEdge(.left, toSuperviewEdge: .left)
            .touchEdge(.right, toSuperviewEdge: .right)
            .touchEdge(.top, toSuperviewEdge: .top)
            .touchEdge(.bottom, toSuperviewEdge: .bottom)
        
        view.sendSubviewToBack(backgroundView)
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
            self.backgroundView.alpha = 1
        } completion: { _ in
            // DEBUG - Для лотти бэкграудн
//            self.backgroundView.play()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .backgroundSecondary
        
        view.layer.masksToBounds = true
        let path = UIBezierPath(roundedRect: view.bounds,
                                byRoundingCorners: [.topRight, .topLeft],
                                cornerRadii: CGSize(width: CGFloat.containerCorner,
                                                    height: CGFloat.containerCorner))

        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        view.layer.mask = maskLayer
    }
    
    private func setRootViewController(_ viewController: UIViewController) {
        viewControllers = [viewController]

        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            viewController.view.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }

    private func transition(from: UIViewController,
                            to: UIViewController,
                            animated: Bool,
                            completion: Action? = nil) {
        guard let containerView = presentationController?.containerView else {
            return
        }
        var fomShimView = UIView()
        fomShimView.backgroundColor = .backgroundSecondary
        fomShimView.alpha = 0
        
        var toShimView = UIView()
        toShimView.backgroundColor = .backgroundSecondary
        toShimView.alpha = 1
        
        addedConstraint(fomShimView: &fomShimView, toShimView: &toShimView, from: from, to: to)
        
        addChild(to)
        view.addSubview(to.view)
        from.willMove(toParent: nil)
        to.willMove(toParent: self)
        
        to.view.alpha = 0

        view.removeConstraints(view.constraints.filter { $0.firstItem === from.view || $0.secondItem === from.view })
        
        from.view.translatesAutoresizingMaskIntoConstraints = false
        to.view.translatesAutoresizingMaskIntoConstraints = false
        
        let fromTop = from.view.topAnchor.constraint(equalTo: view.topAnchor)
        let toTop = to.view.topAnchor.constraint(equalTo: view.topAnchor)
        
        NSLayoutConstraint.activate([
            fromTop,
            from.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            from.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            to.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            to.view.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        view.layoutIfNeeded()
        
        fromTop.isActive = false
        toTop.isActive = true
        
        animatedViews(fomShimView: fomShimView,
                      toShimView: toShimView,
                      to: to,
                      from: from,
                      containerView: containerView,
                      completion: completion)
    }
    
    private func addedConstraint(fomShimView: inout UIView,
                                 toShimView: inout UIView,
                                 from: UIViewController,
                                 to: UIViewController) {
        from.view.addSubview(fomShimView)
        fomShimView.translatesAutoresizingMaskIntoConstraints = false
        to.view.addSubview(toShimView)
        toShimView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fomShimView.bottomAnchor.constraint(equalTo: from.view.bottomAnchor),
            fomShimView.topAnchor.constraint(equalTo: from.view.topAnchor),
            fomShimView.leftAnchor.constraint(equalTo: from.view.leftAnchor),
            fomShimView.rightAnchor.constraint(equalTo: from.view.rightAnchor)
        ])
    
        to.view.addSubview(toShimView)
        toShimView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toShimView.bottomAnchor.constraint(equalTo: to.view.bottomAnchor),
            toShimView.topAnchor.constraint(equalTo: to.view.topAnchor),
            toShimView.leftAnchor.constraint(equalTo: to.view.leftAnchor),
            toShimView.rightAnchor.constraint(equalTo: to.view.rightAnchor)
        ])
        
        fomShimView.layoutIfNeeded()
        toShimView.layoutIfNeeded()
    }
    
    private func animatedViews(fomShimView: UIView,
                               toShimView: UIView,
                               to: UIViewController,
                               from: UIViewController,
                               containerView: UIView,
                               completion: Action?) {
        UIView.animate(
            withDuration: .animationDuration,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1,
            options: .curveEaseOut,
            animations: {
                fomShimView.alpha = 1
            }, completion: { _ in
                to.view.alpha = 1
                completion?()
            }
        )
        
        UIView.animate(
            withDuration: .animationDuration,
            delay: .animationDuration,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1,
            options: .curveEaseOut,
            animations: {
                containerView.layoutIfNeeded()
            }, completion: { _ in
                to.didMove(toParent: self)
                from.removeFromParent()
                from.view.removeFromSuperview()
                from.didMove(toParent: nil)
            }
        )
        
        UIView.animate(
            withDuration: .animationDuration,
            delay: .animationDuration * 2,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1,
            options: .curveEaseOut,
            animations: {
                toShimView.alpha = 0
            }, completion: { _ in
                fomShimView.removeFromSuperview()
                toShimView.removeFromSuperview()
            }
        )
    }
}

extension NSLayoutConstraint {
    
    func withPriority(_ priority: Float) -> NSLayoutConstraint {
        self.priority = UILayoutPriority(priority)
        return self
    }
}

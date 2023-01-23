//
//  ContentNC.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 28.12.2022.
//

import UIKit

private extension TimeInterval {
    static let animationDuration: TimeInterval = 0.45
}

final class ContentNC: UIViewController {
    private lazy var customTransitioningDelegate = CoverTransitioningDelegate()
    private(set) var viewControllers: [UIViewController] = []

    var topViewController: UIViewController? {
        viewControllers.last
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
    
    private func setupUI() {
        view.backgroundColor = .backgroundPrimary
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

    func pushViewController(_ viewController: ContentVC, animated: Bool) {
        guard let from = topViewController else {
            setRootViewController(viewController)
            return
        }
        transition(from: from, to: viewController, animated: animated)
        self.viewControllers.append(viewController)
    }

    @discardableResult
    func popViewController(animated: Bool) -> UIViewController? {
        guard let from = topViewController, from != viewControllers.first else { return nil }

        viewControllers.removeLast()
        if let to = topViewController {
            transition(from: from, to: to, animated: animated)
        }
        return from
    }

    private func transition(from: UIViewController, to: UIViewController, animated: Bool) {
        guard let containerView = presentationController?.containerView else {
            return
        }
        
        addChild(to)
        view.addSubview(to.view)
        from.willMove(toParent: nil)
        to.willMove(toParent: self)
        
        to.view.alpha = 0
        to.view.subviews.forEach({ $0.alpha = 0 })

        view.removeConstraints(view.constraints.filter { $0.firstItem === from.view || $0.secondItem === from.view })
        
        from.view.translatesAutoresizingMaskIntoConstraints = false
        to.view.translatesAutoresizingMaskIntoConstraints = false
        
        let fromTop = from.view.topAnchor.constraint(equalTo: view.topAnchor)
        let toTop = to.view.topAnchor.constraint(equalTo: view.topAnchor)
        
        NSLayoutConstraint.activate([
            fromTop,
            from.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            from.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            from.view.heightAnchor.constraint(lessThanOrEqualToConstant: .vcMaxHeight),
            
            to.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            to.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            to.view.heightAnchor.constraint(lessThanOrEqualToConstant: .vcMaxHeight)
        ])
        
        view.layoutIfNeeded()
        
        fromTop.isActive = false
        toTop.isActive = true
        
        CATransaction.begin()

        UIView.animate(
            withDuration: .animationDuration,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1,
            options: .curveEaseOut,
            animations: {
                from.view.subviews.forEach({ $0.alpha = 0 })
            }, completion: { _ in
                to.view.alpha = 1
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
                to.view.subviews.forEach({ $0.alpha = 1 })
            }, completion: { _ in
                from.view.subviews.forEach({ $0.alpha = 1 })
            }
        )
        
        CATransaction.commit()
    }
}

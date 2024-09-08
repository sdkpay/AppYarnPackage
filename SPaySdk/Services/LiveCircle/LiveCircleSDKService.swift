//
//  LiveCircleService.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 12.11.2022.
//

import UIKit

protocol LiveCircleManager {
    func openInitialScreen(with viewController: UIViewController?,
                           with locator: LocatorService)
    var closeWithGesture: Action? { get set }
    var rootController: RootVC? { get }
    @MainActor
    func closeSDKWindow() async
}

final class DefaultLiveCircleManager: LiveCircleManager {
    private var locator: LocatorService?
    var rootController: RootVC?
    private weak var metchVC: UIViewController?
    private let timeManager: OptimizationCheсkerManager?
    var closeWithGesture: Action?
    var sdkWindow: UIWindow?
    
    init(timeManager: OptimizationCheсkerManager) {
        self.timeManager = timeManager
    }

    func openInitialScreen(with viewController: UIViewController?,
                           with locator: LocatorService) {
        let rootVC = RootAssembly(locator: locator).createModule()
        rootController = rootVC
        metchVC = viewController
        setupWindows(viewController: viewController, locator: locator, rootVC: rootVC)
        self.locator = locator
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    @MainActor
    func closeSDKWindow() async {
        locator?.resolve(NetworkService.self).cancelTask()
        
        await withCheckedContinuation { continuation in
            
            let nillableContinuation: CheckedContinuation<Void, Never>? = continuation
            
            self.rootController?.dismiss(animated: false, completion: {
                nillableContinuation?.resume()
                self.rootController = nil
                self.sdkWindow = nil
            })
        }
    }

    private func setupWindows(viewController: UIViewController?,
                              locator: LocatorService,
                              rootVC: UIViewController) {
        rootVC.modalPresentationStyle = .custom
        if let viewController = viewController {
            viewController.present(rootVC, animated: false)
        } else {
            if let currentWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                sdkWindow = nil
                SBLogger.log("----> Начали инитить Window <----")
                sdkWindow = UIWindow(windowScene: currentWindowScene)
                sdkWindow?.backgroundColor = .clear
                sdkWindow?.windowLevel = .alert + 1
                sdkWindow?.rootViewController = rootVC
                sdkWindow?.makeKeyAndVisible()
            }
        }
    }
    
    private func topVC(for window: UIWindow?) -> UIViewController? {
        var topController: UIViewController? = window?.rootViewController
           while topController?.presentedViewController != nil {
               topController = topController?.presentedViewController
           }
           return topController
    }
}

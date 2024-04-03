//
//  Transition.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 10.10.2023.
//

import UIKit

protocol Transition: AnyObject {
    
    @MainActor
    func performTransition(for viewController: UIViewController)
}

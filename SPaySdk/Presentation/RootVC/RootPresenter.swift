//
//  RootPresenter.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 25.01.2023.
//

import UIKit

protocol RootPresenting {
    func viewDidLoad()
}

final class RootPresenter: RootPresenting {
    private let router: RootRouting

    init(_ router: RootRouting) {
        self.router = router
    }
    
    func viewDidLoad() {
        router.presentAuth()
    }
}

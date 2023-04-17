//
//  PartPayAssembly.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 14.04.2023.
//

import Foundation

final class PartPayAssembly {
    private let locator: LocatorService

    init(locator: LocatorService) {
        self.locator = locator
    }

    func createModule(selectedCard: @escaping (PaymentToolInfo) -> Void) -> ContentVC {
        let presenter = modulePresenter(selectedCard: selectedCard)
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        return contentView
    }

    private func modulePresenter(selectedCard: @escaping (PaymentToolInfo) -> Void) -> PartPayPresenter {
        let presenter = PartPayPresenter(timeManager: OptimizationCheсkerManager(),
                                         analytics: locator.resolve(),
                                         selectedCard: selectedCard)
        return presenter
    }
    
    private func moduleView(presenter: PartPayPresenter) -> ContentVC & IPartPayVC {
        let view = PartPayVC(presenter)
        presenter.view = view
        return view
    }
}

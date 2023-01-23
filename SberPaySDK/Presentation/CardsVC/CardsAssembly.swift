//
//  CardsAssembly.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 05.12.2022.
//

import UIKit

final class CardsAssembly {
    func createModule(manager: SDKManager, analytics: AnalyticsService) -> ContentVC {
        let presenter = modulePresenter(manager, analytics: analytics)
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        return contentView
    }

    private func modulePresenter(_ manager: SDKManager, analytics: AnalyticsService) -> CardsPresenter {
        let presenter = CardsPresenter(manager: manager, analytics: analytics)
        return presenter
    }
    
    private func moduleView(presenter: CardsPresenter) -> ContentVC & ICardsVC {
        let view = CardsVC(presenter)
        presenter.view = view
        return view
    }
}

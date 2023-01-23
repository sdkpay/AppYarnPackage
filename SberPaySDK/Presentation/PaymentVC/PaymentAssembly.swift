//
//  PaymentAssembly.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 23.11.2022.
//

import UIKit

final class PaymentAssembly {
    func createModule(manager: SDKManager, analytics: AnalyticsService) -> ContentVC {
        let presenter = modulePresenter(manager: manager, analytics: analytics)
        let contentView = moduleView(presenter: presenter)
        presenter.view = contentView
        return contentView
    }

    private func modulePresenter(manager: SDKManager, analytics: AnalyticsService) -> PaymentPresenter {
        let presenter = PaymentPresenter(manager, analytics: analytics)
        return presenter
    }
    
    private func moduleView(presenter: PaymentPresenter) -> ContentVC & IPaymentVC {
        let view = PaymentVC(presenter)
        presenter.view = view
        return view
    }
}

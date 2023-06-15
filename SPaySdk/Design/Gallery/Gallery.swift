//
//  Gallery.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 21.11.2022.
//

import UIKit

extension UIImage {
    enum Common {
        static let logoClear = Asset.logoClear.image
        static let logoMain = Asset.logoMain.image
        static let loader = Asset.loader.image
        static let failure = Asset.failure.image
        static let success = Asset.success.image
        static let checkSelected = Asset.checkSelected.image
        static let checkDeselected = Asset.checkDeselected.image
        static let stick = Asset.stick.image
        static let warning = Asset.warning.image
        static let warningAlert = Asset.warningAlert.image
        static let waiting = Asset.waiting.image
        static let checkAgreementSelected = Asset.checkAgreementSelected.image
        static let checkAgreement = Asset.checkAgreement
    }
    enum Payment {
        static let arrow = Asset.arrow.image
        static let cart = Asset.cart.image
    }
    enum UserIcon {
        static let neutral = Asset.neutral.image
        static let male = Asset.male.image
        static let female = Asset.female.image
    }
    enum Cards {
        static let stockCard = Asset.stockCard.image
    }
    enum WebView {
        static let share = Asset.share.image
    }
}

//
//  Gallery.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 21.11.2022.
//

import UIKit

extension UIImage {
    enum Common {
        static let logoClear = Asset.Image.logoClear.image
        static let logoMain = Asset.Image.logoMain.image
        static let failure = Asset.Image.failureState.image
        static let success = Asset.Image.successNew.image
        static let checkSelected = Asset.Image.checkSelected.image
        static let checkDeselected = Asset.Image.checkDeselected.image
        static let stick = Asset.Image.stick.image
        static let warning = Asset.Image.failureState.image
        static let warningAlert = Asset.Image.failureState.image
        static let waiting = Asset.Image.failureState.image
        static let checkAgreementSelected = Asset.Image.checkAgreementSelected.image
        static let checkAgreement = Asset.Image.checkAgreement.image
    }
    enum Payment {
        static let arrow = Asset.Image.arrow.image
        static let cart = Asset.Image.cart.image
    }
    enum UserIcon {
        static let neutral = Asset.Image.neutral.image
        static let male = Asset.Image.male.image
        static let female = Asset.Image.female.image
    }
    enum Cards {
        static let stockCard = Asset.Image.stockCard.image
    }
    enum WebView {
        static let share = Asset.Image.share.image
    }
}

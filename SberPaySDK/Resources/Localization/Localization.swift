//
//  Localization.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 13.01.2023.
//

import Foundation

extension String {
    enum Common {
        /// Оплатить
        static let payTitle = String(stringLiteral: "pay.title")
        /// Отменить
        static let cancelTitle = String(stringLiteral: "cancel.title")
    }

    enum Auth {
        /// Выберите приложение для авторизации в СберБанке
        static let authTitle = String(stringLiteral: "auth.title")
        /// СберБанк Онлайн
        static let sberTitle = String(stringLiteral: "sber.title")
        /// СБОЛ
        static let sbolTitle = String(stringLiteral: "sbol.title")
    }

    enum Cards {
        /// Выберите карту для оплаты
        static let cardsTitle = String(stringLiteral: "cards.title")
    }
    
    enum Loading {
        /// Переходим в СберБанк Онлайн для авторизации
        static let toSberTitle = String(stringLiteral: "toSber.title")
        /// Переходим в СБОЛ для авторизации
        static let toSbolTitle = String(stringLiteral: "toSbol.title")
        ///  Проводим оплату...
        static let tryToPayTitle = String(stringLiteral: "try.to.pay.title")
    }
    
    enum Alert {
        /// Не получилось оплатить.\nПожалуйста, выберите другой способ
        static let alertErrorMainTitle = String(stringLiteral: "alert.error.main.title")
        /// Успешно оплатили
        static let alertPaySuccessTitle = String(stringLiteral: "alert.pay.success.title")
    }
}

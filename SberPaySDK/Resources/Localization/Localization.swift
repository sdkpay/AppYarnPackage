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
        /// Понятно
        static let okTitle = String(stringLiteral: "ok.title")
        /// Вернуться к заказу
        static let returnTitle = String(stringLiteral: "return.title")
        /// Попробовать ещё раз
        static let tryTitle = String(stringLiteral: "try.title")
    }

    enum Auth {
        /// Выберите приложение для авторизации в СберБанке
        static let authTitle = String(stringLiteral: "auth.title")
        /// СберБанк Онлайн
        static let sberTitle = String(stringLiteral: "sber.title")
        /// СБОЛ
        static let sbolTitle = String(stringLiteral: "sbol.title")
    }
    
    enum Payment {
        /// Нет карт для оплаты
        static let noCardsTitle = String(stringLiteral: "payment.noCards.title")
        /// Выберите другой способ
        static let noCardsSubtitle = String(stringLiteral: "payment.noCards.subtitle")
    }

    enum Cards {
        /// Выберите карту для оплаты
        static let cardsTitle = String(stringLiteral: "cards.title")
    }

    enum Error {
        /// Системная или внутренняя ошибка.
        static let errorSystem = String(stringLiteral: "error.system")
        /// Некорректный формат запроса/ответа.
        static let errorFormat = String(stringLiteral: "error.format")
        /// Клиент закрыл SDK.
        static let errorClose = String(stringLiteral: "error.close")
        /// Истек таймаут ожидания ответа с сервера.
        static let errorTimeout = String(stringLiteral: "error.timeout")
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
        /// Нет подходящих карт. Вернитесь к заказу\nи выберите другой способ оплаты.
        static let alertPayNoCardsTitle = String(stringLiteral: "alert.pay.no.cards.title")
        /// Обрабатываем оплату. Следите за статусом в Истории приложения СберБанк Онлайн.
        static let alertPayWaitingTitle = String(stringLiteral: "alert.pay.waiting.title")
        /// Нет интернета. Проверьте подключение и попробуйте ещё раз.
        static let alertPayNoInternetTitle = String(stringLiteral: "alert.pay.no.internet.title")
    }
}

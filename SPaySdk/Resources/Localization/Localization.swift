//
//  Localization.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 13.01.2023.
//

import Foundation

extension String {
    enum Common {
        /// Оплатить
        static let payTitle = Strings.Pay.title
        /// Оплатить полностью
        static let payFull = Strings.Pay.Full.title
        /// Отменить
        static let cancelTitle = Strings.Cancel.title
        /// Понятно
        static let okTitle = Strings.Ok.title
        /// К способам оплаты
        static let returnTitle = Strings.Return.title
        /// Попробовать ещё раз
        static let tryTitle = Strings.Try.title
        /// Вернуться
        static let backTitle = Strings.Back.title
        /// %@ из  %@
        static func fromTitle(args: CVarArg...) -> String {
            Strings.From.title(args)
        }
    }
    
    enum Payment {
        /// Нет карт для оплаты
        static let noCardsTitle = Strings.Payment.NoCards.title
        /// Выберите другой способ
        static let noCardsSubtitle = Strings.Payment.NoCards.subtitle
    }

    enum Cards {
        /// Выберите карту для оплаты
        static let cardsTitle = Strings.Cards.title
    }
    
    enum PayPart {
        /// Плати частями
        static let title = Strings.Part.Pay.title
        /// 4 платежа раз в 2 недели
        static let subtitle = Strings.Part.Pay.subtitle
        /// Подтвердить
        static let accept =  Strings.Accept.title
        /// Оплатить полностью
        static let cancel = Strings.Part.Pay.Cancel.title
        /// Итого
        static let final = Strings.Part.Pay.final
        /// Условия договора
        static let agreement = Strings.Agreement.title
    }

    enum Error {
        /// Системная или внутренняя ошибка.
        static let errorSystem = Strings.Error.system
        /// Некорректный формат запроса/ответа.
        static let errorFormat = Strings.Error.format
        /// Клиент закрыл SDK.
        static let errorClose = Strings.Error.close
        /// Истек таймаут ожидания ответа с сервера.
        static let errorTimeout = Strings.Error.timeout
    }
    
    enum Loading {
        ///  Проводим оплату...
        static let tryToPayTitle = Strings.Try.To.Pay.title
        /// Переходим в %@ для авторизации
        static func toBankTitle(args: CVarArg...) -> String {
            Strings.To.Bank.title(args)
        }
        ///  Подгружаем ваши данные
        static let getData = Strings.Get.Data.title
    }
    
    enum Alert {
        /// Не получилось оплатить.\nПожалуйста, выберите другой способ
        static let alertErrorMainTitle = Strings.Alert.Error.Main.title
        /// Успешно оплатили
        static let alertPaySuccessTitle = Strings.Alert.Pay.Success.title
        /// Нет подходящих карт. Вернитесь к заказу\nи выберите другой способ оплаты.
        static let alertPayNoCardsTitle = Strings.Alert.Pay.No.Cards.title
        /// Нет интернета. Проверьте подключение и попробуйте ещё раз.
        static let alertPayNoInternetTitle = Strings.Alert.Pay.No.Internet.title
        /// Обрабатываем оплату. Следите за статусом в Истории приложения @
        static func waiting(args: CVarArg...) -> String {
            Strings.Alert.Pay.No.Waiting.title(args)
        }
        /// Сервис оплаты частями недоступен. Оплатите заказ полностью или выберите другой способ оплаты.
        static let alertPartPayError = Strings.Alert.Pay.Error.title
    }
    
    enum MerchantAlert {
        static let alertApiKey = Strings.Merchant.Alert.apikey
        static let alertVersion = Strings.Merchant.Alert.version
    }
    
    enum Fake {
        static let fakeTitle = Strings.Fake.title
    }
}

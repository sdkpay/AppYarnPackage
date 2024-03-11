//
//  AnalyticsService.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 28.12.2022.
//

import Foundation

final class AnalyticsServiceAssembly: Assembly {
    
    var type = ObjectIdentifier(AnalyticsService.self)
    
    func register(in locator: LocatorService) {
        let service: AnalyticsService = DefaultAnalyticsService(authManager: locator.resolve())
        locator.register(service: service)
    }
}

enum AnlyticsScreenEvent: String {
    case AuthVC
    case CardsVC
    case OtpVC
    case PartPayVC
    case PaymentVC
    case WebViewVC
    case None
}

enum AnalyticsEvent: String {
    /// Версия SDK
    case SDKVersion
    /// Не найдено приложение Банка на устройстве
    case LCNoBankAppFound
    /// Найдено приложение Банка на устройстве
    case LCBankAppFound
    /// Отобразился экран выбора приложения для авторизации (кейс, когда стоят два приложения)
    case LCBankAppsViewAppeared
    /// Перестал отображаться экран выбора приложения для авторизации (кейс, когда стоят два приложения)
    case LCBankAppsViewDisappeared
    /// Отправлен запрос на remote config
    case RQRemoteConfig
    ///  Получен положительный ответ на запрос получения  remote config
    case RQGoodRemoteConfig
    ///  Получена ошибка на запрос получения  remote config
    case RQFailRemoteConfig
    ///  Получена ошибка при декодировании remote config
    case RSFailRemoteConfig
    /// Отправлен запрос на получение сессии
    case RQSessionId
    /// Получен положительный ответ на запрос получения SessionId
    case RQGoodSessionId
    /// Парсинг ответа от сервера на запрос SessionId произведен с ошибкой
    case RQFailSessionId
    /// Парсинг ответа от сервера на запрос SessionId проведен успешно
    case RSGoodSessionId
    /// Получена ошибка от шлюза при обработке запроса SessionId
    case RSFailSessionId
    /// Отправлен запрос auth
    case RQAuth
    /// Получен положительный ответ на запрос получения auth
    case RQGoodAuth
    /// Получена ошибка при обработке запроса auth
    case RQFailAuth
    /// Парсинг ответа от сервера на запрос auth проведен успешно
    case RSGoodAuth
    /// Парсинг ответа от сервера на запрос auth произведен с ошибкой
    case RSFailAuth
    /// Отправлен запрос на получение ListCards
    case RQListCards
    /// Получен положительный ответ на запрос получения ListCards
    case RQGoodListCards
    /// Парсинг ответа от сервера на запрос ListCards проведен успешно
    case RSGoodListCards
    /// Получена ошибка от шлюза при обработке запроса ListCards
    case RQFailListCards
    ///  Получена ошибка при парсинге ListCards
    case RSFailListCards
    /// Отправлен запрос на получение BNPL
    case RQBnpl
    /// Получен положительный ответ на запрос получения BNPL
    case RQGoodBnpl
    /// Получена ошибка от шлюза при обработке запроса BNPL
    case RQFailBnpl
    /// Парсинг ответа от сервера на запрос BNPL проведен успешно
    case RSGoodBnpl
    /// Парсинг ответа от сервера на запрос SessionId произведен с ошибкой
    case RSFailBnpl
    /// Достали из хранилища Refresh token
    case STGetGoodRefresh
    /// Не смогли получить из хранилища Refresh token
    case STGetFailRefresh
    /// Не удалось достать выбранный банк
    case STGetFailBankApp
    /// Сохранили Refresh token
    case STSaveRefresh
    ///  Сохранили приложение банка выбранного пользователем
    case STSaveBankApp
    /// Отобразился экран авторизации
    case LCBankAuthViewAppeared
    /// Перестал отображаться экран авторизации
    case LCBankAuthViewDisappeared
    /// Система вызвала переход в приложение банка
    case LCBankAppAuth
    /// Пользователь прошел авторизацию в банке
    case LCBankAppAuthGood
    /// Пользователь получил ошибку при авторизации в банке
    case LCBankAppAuthFail
    /// Пользователь нажал на ячейку с картой
    case TouchCard
    /// Кнопка оплаты проиницализирована
    case TouchBNPL
    /// Пользователь нажал на ячейку с BNPL
    case TouchPay
    /// Пользователь нажал кнопку Продолжит
    case TouchNext
    /// Пользователь нажал на кнопку отмены оплаты
    case TouchCancel
    /// Отправлен запрос PaymentToken
    case RQPaymentToken
    /// Получен положительный ответ на запрос получения PaymentToken
    case RQGoodPaymentToken
    /// Парсинг ответа от сервера на запрос PaymentToken произведен с ошибкой
    case RQFailPaymentToken
    /// Парсинг ответа от сервера на запрос PaymentToken проведен успешно
    case RSGoodPaymentToken
    /// Получена ошибка от шлюза при обработке запроса PaymentToken
    case RSFailPaymentToken
    /// Отправлен запрос на получение ListCards
    case RQPaymentOrder
    /// Получен положительный ответ на запрос получения ListCards
    case RQGoodPaymentOrder
    /// Получена ошибка от шлюза при обработке запроса ListCards
    case RQFailPaymentOrder
    /// Парсинг ответа от сервера на запрос ListCards проведен успешно
    case RSGoodPaymentOrder
    /// Парсинг ответа от сервера на запрос ListCards произведен с ошибкой
    case RSFailPaymentOrder
    /// Вызвана системная авторизация по биометрии
    case LСBioAuthStart
    /// Системная авторизация по биометрии прошла успешно
    case LСGoodBioAuth
    /// Системная авторизация по биометрии вернула ошибку
    case LСFailBioAuth
    /// Отобразился экран списка карт
    case LCPayViewAppeared
    /// Перестал отображаться экран списка карт
    case LCPayViewDisappeared
    /// Пользователь нажал на кнопку "Подтвердить оплату частями"
    case TouchConfirmedByUser
    /// Пользователь нажал на кнопку "Не хочу платить частями"
    case TouchDeclinedByUser
    /// Пользователь нажал на галочку соглашения с условиями
    case TouchApproveBNPL
    /// Пользователь перешел по ссылке "Условия договора"
    case TouchContractView
    /// Пользователь перешел по ссылке "Соглашение"
    case TouchAgreementView
    /// Отобразился экран оплаты
    case LCBNPLViewAppeared
    /// Перестал отображаться экран оплаты
    case LCBNPLViewDisappeared
    /// Пользователь нажал на кнопку "Вернуться"
    case TouchBack
    /// Пользователь нажал на кнопку "Поделиться"
    case TouchShare
    /// Отобразился экран оплаты
    case LCWebViewAppeared
    /// Перестал отображаться экран оплаты
    case LCWebViewDisappeared
    /// Отправлен запрос на получение CreteOTP
    case RQCreteOTP
    /// Получен положительный ответ на запрос получения CreteOTP
    case RQGoodCreteOTP
    ///  Парсинг ответа на запрос получения CreteOTP успешен
    case RSGoodCreteOTP
    /// Получена ошибка от шлюза при обработке запроса CreteOTP
    case RQFailCreteOTP
    /// Парсинг ответа от сервера на запрос CreteOTP произведен с ошибкой
    case RSFailCreteOTP
    /// Отправлен запрос на получение ConfirmOTP
    case RQConfirmOTP
    /// Парсинг ответа на запрос получения ConfirmOTP успешен
    case RSConfirmOTP
    /// Получен положительный ответ на запрос получения ConfirmOTP
    case RQGoodConfirmOTP
    /// Получена ошибка от шлюза при обработке запроса ConfirmOTP
    case RQFailConfirmOTP
    /// Парсинг ответа от сервера на запрос ConfirmOTP проведен успешно
    case RSGoodConfirmOTP
    /// Парсинг ответа от сервера на запрос ConfirmOTP произведен с ошибкой
    case RSFailConfirmOTP
    /// Отобразился экран оплаты
    case LCOTPViewAppeared
    /// Перестал отображаться экран оплаты
    case LCOTPViewDisappeared
    /// Пользователь нажал на кнопку "Подтвердить оплату частями"
    case TouchTopButton
    /// Пользователь нажал на кнопку "Не хочу платить частями"
    case TouchBottomButton
    /// Отобразился экран статуса оплаты с  успехом
    case LCStatusSuccessViewAppeared
    /// Отобразился экран статуса оплаты в прогрессе
    case LCStatusInProgressViewAppeared
    /// Отобразился экран статуса в состоянии ошибки
    case LCStatusErrorViewAppeared
    /// Перестал отображаться экран статуса
    case LCStatusViewDisappeared
    /// Метод инициализации SDK
    case MAInit
    /// Мерчант вызвал метод isReadyForSPay
    case MAIsReadyForSPay
    /// Мерчант вызвал метод getPaymentToken
    case MAGetPaymentToken
    /// Мерчант получил ответ на метод getPaymentToken
    case MACGetPaymentToken
    /// Мерчант вызвал метод pay
    case MAPay
    /// Мерчант получил ответ на метод pay
    case MACPay
    /// Мерчант вызвал метод payWithBankInvoiceId
    case MAPayWithBankInvoiceId
    /// Мерчант получил ответ на метод payWithBankInvoiceId
    case MACPayWithBankInvoiceId
    /// Мерчант вызвал метод completePayment
    case MACompletePayment
    /// Мерчант получил ответ на метод completePayment
    case MACCompletePayment
    /// Метод для авторизации банка
    case MAGetAuthURL
    /// Запуск логики по запросу необходимых разрешений
    case SCPermissions
    /// Все запрашиваемые разрешения были выданы
    case SCGoodPermissions
    /// Не все либо ни одно из разрешений не было выдано
    case SCFailPermissions
    /// Запуск логики SPaySDK бизоном
    case SCBiZone
    /// Проверка SPaySDK прошла успешно
    case SCGoodBiZone
    /// Проверка SPaySDK была провалена
    case SCFailBiZone
}

enum AnalyticsValue: String {
    case Location
}

enum AnalyticsKey: String {
    case View
    case OrderNumber
    case SessionId
    case ErrorCode
    case ParsingError
    case HttpCode
    case Permisson
    case BiZoneCode
    case State
}

protocol AnalyticsService {
    func sendEvent(_ event: AnalyticsEvent)
    func sendEvent(_ event: AnalyticsEvent, with string: String)
    func sendEvent(_ event: AnalyticsEvent, with dictionaty: [AnalyticsKey: Any])
    func config()
    func startSession()
    func finishSession()
}

final class DefaultAnalyticsService: NSObject, AnalyticsService {
    
    func startSession() {
        analyticServices.forEach { $0.startSession() }
    }
    
    func finishSession() {
        analyticServices.forEach { $0.finishSession() }
    }
    
    private lazy var analyticServices: [AnalyticsService] = [
        DefaultDynatraceAnalyticsService()
    ]
    
    private var authManager: AuthManager
    
    func sendEvent(_ event: AnalyticsEvent) {
        
        analyticServices.forEach({ $0.sendEvent(event) })
    }
    
    func sendEvent(_ event: AnalyticsEvent, with string: String) {
        
        analyticServices.forEach({ $0.sendEvent(event, with: string) })
    }
    
    func sendEvent(_ event: AnalyticsEvent, with dictionaty: [AnalyticsKey: Any]) {
        
        var dict = dictionaty
        addSessionParams(to: &dict)
        analyticServices.forEach({ $0.sendEvent(event, with: dict) })
    }
    
    init(authManager: AuthManager) {
        self.authManager = authManager
        super.init()
        SBLogger.log(.start(obj: self))
    }
    
    deinit {
        self.finishSession()
        SBLogger.log(.stop(obj: self))
    }
    
    func config() {
        analyticServices.forEach({ $0.config() })
        sendEvent(.SDKVersion, with: Bundle.sdkVersion)
        startSession()
    }
    
    private func addSessionParams(to dictionary: inout [AnalyticsKey: Any]) {
        
        dictionary[.OrderNumber] = authManager.orderNumber
        dictionary[.SessionId] = authManager.sessionId
    }
}

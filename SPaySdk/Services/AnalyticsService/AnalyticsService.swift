//
//  AnalyticsService.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 28.12.2022.
//

import Foundation

final class AnalyticsServiceAssembly: Assembly {
    func register(in locator: LocatorService) {
        let service: AnalyticsService = DefaultAnalyticsService()
        locator.register(service: service)
    }
}

enum AnalyticsEvent: String {
    /// Версия SDK
    case SDKVersion
    /// Не найдено приложение Банка на устройстве
    case NoBankAppFound
    /// Найдено приложение Банка на устройстве
    case BankAppFound
    /// Отобразился экран выбора приложения для авторизации (кейс, когда стоят два приложения)
    case BankAppsViewAppear
    /// Отобразился стандартный первый экран шторки с предупреждением о переходе в приложение Банка для авторизации
    case AuthViewAppeared
    /// Юзер не согласился с открытием приложения Банка, нажал "Отменить" в системной модалке
    case RedirectDenied
    /// Юзер успешно аутентифицировался в приложении Банка и был возвращен в приложение Мерчанта
    case BankAppAuthSuccess
    /// Юзер не прошел аутентификацию в приложении Банка
    case BankAppAuthFailed
    /// Юзер не прошел аутентификацию при проверке на бэкэнде
    case BackAuthFailed
    /// Отразился основной экран с картами и профилем
    case PayViewAppeared
    /// Не смогли показать основной экран с картами и профилем
    case PayViewFailed
    /// Юзер перешел к списку карт
    case CardsViewAppeared
    /// Юзер подтвердил оплату
    case PayConfirmedByUser
    /// Оплата успешна
    case PaySuccess
    /// Оплата отклонена
    case PayFailed
    /// Пользователь самостоятельно закрыл шторку сдк
    case ManuallyClosed
    /// Пермиссии данные пользоватлем к моменту оплаты
    case Permissions
    ///  Размер загруженных локальных данных
    case DataSize
    ///  Время, необходимое для запуск SDK
    case StartTime
    /// Открыли экран с графиком платежей
    case BNPLViewAppeared
    /// Пользователь выбрал оплату с БНПЛ на экране с графиком платежей
    case BNPLConfirmedByUser
    /// Пользователь выбрал оплату без БНПЛ на экране с графиком платежей
    case BNPLDeclinedByUser
    /// Клиент подтвердил оплату с включенным БНПЛ
    case PayWithBNPLConfirmedByUser
    /// Открыли экран с ошибкой оплаты с БНПЛ
    case PayWithBNPLFailed
    /// Пользователь перешел по ссылке "Условия договора"
    case PayWithBNPLContractView
    /// Пользователь перешел по ссылке "Соглашение"
    case PayWithBNPLAgreementView
    /// Проверка устройства на возможность запуска команды с привилегиями пользователя root
    case Compromised
    ///  Проверка устройства на эмуляцию
    case Emulator
    ///  Ошибка 404 (в эвенте передаем эндпоинт)
    case Error404
    ///  Ошибка валидации ответа (в эвенте передаем эндпоинт)
    case DecodeError
    ///  Timeout  (в эвенте передаем эндпоинт)
    case Timeout
    ///  Изначальная настройка SDK
    case Setup
    ///  Готовность работать с SDK
    case IsReadyForSPay
    ///  Получение платежного токена
    case GetPaymentToken
    /// Оплата
    case Pay
    /// Оплата с id
    case PayWithOrderId
    /// Окончание оплаты
    case CompletePayment
    /// Получение url
    case GetResponseFrom
    /// Уровень соединения
    case DebugConfig
    /// вызова статус сешн: успешно восстановили сессию после смахивания
    case RepairSessionSuccess
    /// вызова статус сешн: неуспешно
    case RepairSessionFailed
    /// Оплата в обработке
    case PayProcess
}

enum AnalyticsValue: String {
    case Location
}

protocol AnalyticsService {
    func sendEvent(_ event: AnalyticsEvent)
    func sendEvent(_ event: AnalyticsEvent, with strings: String...)
    func sendEvent(_ event: AnalyticsEvent, with ints: Int...)
    func sendEvent(_ event: AnalyticsEvent, with doubles: Double...)
    func sendEvent(_ event: AnalyticsEvent, with strings: [String])
    func sendEvent(_ event: AnalyticsEvent, with ints: [Int])
    func sendEvent(_ event: AnalyticsEvent, with doubles: [Double])
    func config()
}

final class DefaultAnalyticsService: NSObject, AnalyticsService {
    private lazy var analyticServices: [AnalyticsService] = [
        DefaultDynatraceAnalyticsService()
    ]
    
    func sendEvent(_ event: AnalyticsEvent) {
        analyticServices.forEach({ $0.sendEvent(event) })
    }
    
    func sendEvent(_ event: AnalyticsEvent, with strings: String...) {
        analyticServices.forEach({ $0.sendEvent(event, with: strings) })
    }
    
    func sendEvent(_ event: AnalyticsEvent, with ints: Int...) {
        analyticServices.forEach({ $0.sendEvent(event, with: ints) })
    }
    
    func sendEvent(_ event: AnalyticsEvent, with doubles: Double...) {
        analyticServices.forEach({ $0.sendEvent(event, with: doubles) })
    }
    
    func sendEvent(_ event: AnalyticsEvent, with strings: [String]) {
        analyticServices.forEach({ $0.sendEvent(event, with: strings) })
    }
    
    func sendEvent(_ event: AnalyticsEvent, with ints: [Int]) {
        analyticServices.forEach({ $0.sendEvent(event, with: ints) })
    }
    
    func sendEvent(_ event: AnalyticsEvent, with doubles: [Double]) {
        analyticServices.forEach({ $0.sendEvent(event, with: doubles) })
    }
    
    override init() {
        super.init()
        SBLogger.log(.start(obj: self))
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    func config() {
        analyticServices.forEach({ $0.config() })
        sendEvent(.SDKVersion, with: Bundle.sdkVersion)
    }
}

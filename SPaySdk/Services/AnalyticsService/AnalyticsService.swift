//
//  AnalyticsService.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 28.12.2022.
//

import Foundation
@_implementationOnly import DynatraceStatic

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
    /// Проверка устройства на возможность запуска команды с привилегиями пользователя root
    case Compromised
    ///  Проверка устройства на эмуляцию
    case Emulator
}

enum AnalyticsValue: String {
    case Location
}

protocol AnalyticsService {
    func sendEvent(_ event: AnalyticsEvent)
    func sendEvent(_ event: AnalyticsEvent, with strings: [String])
    func sendEvent(_ event: AnalyticsEvent, with ints: [Int])
    func sendEvent(_ event: AnalyticsEvent, with doubles: [Double])
    func config()
}

final class DefaultAnalyticsService: NSObject, AnalyticsService {
    func sendEvent(_ event: AnalyticsEvent) {
        let action = DTXAction.enter(withName: event.rawValue)
        action?.leave()
    }
    
    func sendEvent(_ event: AnalyticsEvent, with strings: [String]) {
        let action = DTXAction.enter(withName: event.rawValue)
        strings.forEach({ action?.reportValue(withName: event.rawValue, stringValue: $0) })
        action?.leave()
    }
    
    func sendEvent(_ event: AnalyticsEvent, with ints: [Int]) {
        let action = DTXAction.enter(withName: event.rawValue)
        ints.forEach({ action?.reportValue(withName: event.rawValue, intValue: Int64($0)) })
        action?.leave()
    }
    
    func sendEvent(_ event: AnalyticsEvent, with doubles: [Double]) {
        let action = DTXAction.enter(withName: event.rawValue)
        doubles.forEach({ action?.reportValue(withName: event.rawValue, doubleValue: $0) })
        action?.leave()
    }

    override init() {
        super.init()
        SBLogger.log(.start(obj: self))
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    func config() {
        let startupDictionary: [String: Any?] = [
            kDTXApplicationID: ConfigGlobal.schemas?.dynatraceId,
            kDTXBeaconURL: ConfigGlobal.schemas?.dynatraceUrl,
            kDTXLogLevel: "OFF"
        ]
        Dynatrace.startup(withConfig: startupDictionary as [String: Any])
        Dynatrace.identifyUser(Bundle.main.displayName)
        sendEvent(.SDKVersion, with: [Bundle.sdkVersion])
    }
}

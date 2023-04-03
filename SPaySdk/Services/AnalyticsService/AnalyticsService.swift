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
}

enum AnalyticsValue: String {
    case Location
}

protocol AnalyticsService {
    func sendEvent(_ event: AnalyticsEvent)
    func sendEvent<T>(_ event: AnalyticsEvent, with value: [T])
}

final class DefaultAnalyticsService: NSObject, AnalyticsService {
    func sendEvent(_ event: AnalyticsEvent) {
        let action = DTXAction.enter(withName: event.rawValue)
        action?.leave()
    }
    
    func sendEvent<T>(_ event: AnalyticsEvent, with values: [T]) {
        let action = DTXAction.enter(withName: event.rawValue)
        for value in values {
            if let value = value as? String {
                action?.reportValue(withName: event.rawValue, stringValue: value)
            } else if let value = value as? Int64 {
                action?.reportValue(withName: event.rawValue, intValue: value)
            } else if let value = value as? Double {
                action?.reportValue(withName: event.rawValue, doubleValue: value)
            } else {
                print("Bad type for value")
            }
        }
        action?.leave()
    }

    override init() {
        super.init()
        configDynatrace()
        SBLogger.log(.start(obj: self))
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    private func configDynatrace() {
        let startupDictionary: [String: Any?] = [
            kDTXApplicationID: AppSettings.dynatraceId,
            kDTXBeaconURL: AppSettings.dynatraceUrl,
            kDTXLogLevel: AppSettings.dynatraceLogLevel
        ]
        Dynatrace.startup(withConfig: startupDictionary as [String: Any])
        Dynatrace.identifyUser(Bundle.main.displayName)
        sendEvent(.SDKVersion, with: [Bundle.sdkVersion])
    }
}

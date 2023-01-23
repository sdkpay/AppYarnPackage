//
//  SBError.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 11.11.2022.
//

import Foundation

public enum SDKError: Error {
    case noInternetConnection
    case noData
    case badResponseWithStatus(code: Int)
    case failDecode
    case badDataFromSBOL
    case unauthorizedClient
    case errorFromServer(text: String)
    case cancelled
    
    // DEBUG
    // Несогласованные тексты ошибок
    var description: String {
        switch self {
        case .noInternetConnection:
            return "Нет интернет соединения."
        case .noData:
            return "Данные не получены."
        case .errorFromServer(let text):
            return text
        case .badDataFromSBOL:
            return "Неверный ответ от приложения банка."
        case .unauthorizedClient:
            return "Источник запроса не зарегистрирован в банке."
        case .cancelled:
            return "Пользователь закрыл SberPay."
        default:
            return localizedDescription
        }
    }
}

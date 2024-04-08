//
//  ExchangeTokenModel.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 27.11.2023.
//

import Foundation

/// Модель ответа на запрос exchangeToken
struct ExchangeTokenModel: Codable {

    /// Scope на который выдается токен
    var scope: [Scope]

    /// TransitToken для перехода на партнера2
    var accessToken: String

    /// Тип токена
    var tokenType: TokenType

    /// Время истечения срока действия TT в сек. с момента создания ответа
    var expiresIn: Int

    /// Scope на который выдается токен
    struct Scope: Codable {

        /// Тип запрашиваемой области доступа
        var type: String
    }

    enum TokenType: String, Codable {
        case bearer = "Bearer"
    }

    enum CodingKeys: String, CodingKey {
        case scope
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}

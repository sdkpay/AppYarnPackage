//
//  SBError.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 11.11.2022.
//

import Foundation

enum SDKError: Error, Hashable {
    case noInternetConnection
    case noData
    case badResponseWithStatus(code: Int)
    case failDecode
    case badDataFromSBOL
    case unauthorizedClient
    case personalInfo
    case errorFromServer(text: String)
    case noCards
    case cancelled
    case timeOut
    
    func represents(_ error: SDKError) -> Bool {
        self == error
    }
}

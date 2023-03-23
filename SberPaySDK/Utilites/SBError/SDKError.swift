//
//  SBError.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 11.11.2022.
//

import Foundation

enum StatusCode: Int {
    case unknownPayState = 423
    case errorFormat = 400
    case errorSystem = 500
    case unowned
}

enum SDKError: Error, Hashable {
    case noInternetConnection
    case noData
    case badResponseWithStatus(code: StatusCode)
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

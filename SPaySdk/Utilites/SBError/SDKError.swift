//
//  SBError.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 11.11.2022.
//

import Foundation

enum StatusCode: Int {
    case unknownState = 403
    case unknownPayState = 423
    case errorFormat = 400
    case errorPath = 404
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
    case ssl
    
    func represents(_ error: SDKError) -> Bool {
        self == error
    }
}

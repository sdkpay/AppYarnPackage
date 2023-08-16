//
//  ConfigValues.swift
//  SberPay
//
//  Created by Alexander Ipatov on 07.11.2022.
//

import Foundation
import SPaySdkDEBUG

struct PerchaseConfig: Codable {
    let currency: String?
    let mobilePhone: String?
    let orderNumber: String?
    let orderId: String?
    let orderDescription: String?
    let language: String?
    let recurrentExipiry: String?
    let recurrentFrequency: Int
}

enum RequestMethod: String, CaseIterable, Codable {
    case OrderId, Purchase
}

enum PayMode: String, CaseIterable, Codable {
    case Manual, Auto
}

enum Lang: String, CaseIterable, Codable {
    case Swift, Obj
}

enum Environment: String, CaseIterable, Codable {
    case Prod
    case SandboxWithoutBankApp
    case SandboxRealBankApp
}

struct ConfigValues {
    @UserDefault(key: CellType.apiKey.rawValue,
                 defaultValue: "APgWA9brxUPpgEz/Qj0dHR4AAAAAAAAADDR8ezdUy7tW0Vvns+yzeJ8FMyClHvqjIdqYmXxYJ3MXG+CaM15S/073vf1A3RoXNTrl1DPxKEkvPBetfoURU7DBI0bkqayEmRROmV6Yu7vlgTwnyJt+88884H7yezp8lEkQ4/dRVlQgYChKGC1Hyi25i9I1TMA+SgxudCUwWMLJ7t7BgQ8wMgCAsLY=") // swiftlint:disable:this line_length
    var apiKey: String?
    
    @UserDefault(key: CellType.cost.rawValue,
                 defaultValue: 2000)
    var cost: Int
    
    @UserDefault(key: CellType.merchantLogin.rawValue,
                 defaultValue: "test_sberpay")
    var merchantLogin: String?
    
    @UserDefault(key: CellType.configMethod.rawValue,
                 defaultValue: RequestMethod.OrderId)
    var configMethod: RequestMethod
    
    @UserDefault(key: CellType.orderId.rawValue,
                 defaultValue: "23fc772ae8944aac8434944774630ae7")
    var orderId: String?

    @UserDefault(key: CellType.orderNumber.rawValue,
                 defaultValue: "5f3f7d10-7005-7afe-b756-f73001c896b1")
    var orderNumber: String?

    @UserDefault(key: CellType.lang.rawValue,
                 defaultValue: Lang.Swift)
    var lang: Lang
    
    @UserDefault(key: CellType.mode.rawValue,
                 defaultValue: PayMode.Auto)
    var mode: PayMode

    @UserDefault(key: CellType.environment.rawValue,
                 defaultValue: Environment.Prod)
    var environment: Environment
    
    @UserDefault(key: CellType.network.rawValue,
                 defaultValue: NetworkState.Prom)
    var network: NetworkState
    
    @UserDefault(key: CellType.currency.rawValue,
                 defaultValue: 643)
    var currency: Int

    @UserDefault(key: CellType.ssl.rawValue,
                 defaultValue: true)
    var ssl: Bool
    
    @UserDefault(key: CellType.refresh.rawValue,
                 defaultValue: true)
    var refresh: Bool
    
    @UserDefault(key: CellType.bnpl.rawValue,
                 defaultValue: true)
    var bnpl: Bool
}

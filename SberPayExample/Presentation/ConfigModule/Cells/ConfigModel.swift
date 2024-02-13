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
                 defaultValue: "AJpyllTD+0LKpCMDVZEB2ecAAAAAAAAADDLBcwrQjr5bOjn3yzYlFpCBk1nyQ9J46Ar3DrFBNyA92UJ7g/8zwuNose2pNnduv8JnjxD4h3HXdK8jTQB3pu7/HWqntPpBUCaA/8wqXK/gbgbJdWCU/7hzbtdYkxSD0u3qau9/4wM1p9WgkzNEPtPJE/gRKMk=") // swiftlint:disable:this line_length
    var apiKey: String?
    
    @UserDefault(key: CellType.cost.rawValue,
                 defaultValue: 2000)
    var cost: Int
    
    @UserDefault(key: CellType.merchantLogin.rawValue,
                 defaultValue: "mineev_sdk")
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
    
    @UserDefault(key: CellType.helpers.rawValue,
                 defaultValue: true)
    var helpers: Bool
    
    @UserDefault(key: CellType.sbp.rawValue,
                 defaultValue: true)
    var sbp: Bool
    
    @UserDefault(key: CellType.newCreditCard.rawValue,
                 defaultValue: true)
    var newCreditCard: Bool
    
    @UserDefault(key: CellType.newDebitCard.rawValue,
                 defaultValue: true)
    var newDebitCard: Bool
}

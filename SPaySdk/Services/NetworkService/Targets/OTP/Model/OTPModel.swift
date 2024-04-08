//
//  OTPModel.swift
//  SPaySdk
//
//  Created by Арсений on 03.08.2023.
//

import Foundation

struct OTPModel: Codable {
    let errorCode: String
    let errorMessage: String?
    let mobilePhone: String?
}

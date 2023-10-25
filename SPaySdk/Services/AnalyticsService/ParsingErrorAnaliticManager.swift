//
//  ParsingErrorAnaliticManager.swift
//  SPaySdk
//
//  Created by admin on 23.10.2023.
//

import Foundation

public enum OtpTypeRequest {
    case creteOTP
    case confirmOTP
}

public enum AuthRequestType {
    case auth
    case sessionId
}

public enum PaymentRequestType {
    case paymentOrder
    case paymentToken
}

public enum AnaliticTypeRequest {
    case otp(type: OtpTypeRequest)
    case auth(type: AuthRequestType)
    case bnpl
    case payment(type: PaymentRequestType)
    case remote
    case listCards
}

final class ParsingErrorAnaliticManagerAssembly: Assembly {
    func register(in locator: LocatorService) {
        let service: ParsingErrorAnaliticManager = DefaultParsingErrorAnaliticManager(analytics: locator.resolve())
        locator.register(service: service)
    }
}

protocol ParsingErrorAnaliticManager {
    func sendAnaliticsError(error: SDKError, type: AnaliticTypeRequest)
}

public final class DefaultParsingErrorAnaliticManager: ParsingErrorAnaliticManager {
    
    private let analytics: AnalyticsService
    
    init(analytics: AnalyticsService) {
        self.analytics = analytics
    }
    
    func sendAnaliticsError(error: SDKError, type: AnaliticTypeRequest) {
        let result = parseAnaliticsType(type: type)

        switch error {
            
        case .noInternetConnection:
            self.analytics.sendEvent(
                result.0,
                with:
                    [
                        AnalyticsKey.httpCode: StatusCode.errorSystem.rawValue,
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: result.2
                    ]
            )
        case .noData:
            self.analytics.sendEvent(
                result.0,
                with:
                    [
                        AnalyticsKey.httpCode: StatusCode.errorSystem.rawValue,
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: result.2
                    ]
            )
        case .badResponseWithStatus(let code):
            self.analytics.sendEvent(
                result.0,
                with:
                    [
                        AnalyticsKey.httpCode: code.rawValue,
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: result.2
                    ]
            )
        case .failDecode(let text):
            self.analytics.sendEvent(
                result.0,
                with:
                    [
                        AnalyticsKey.httpCode: Int64(200),
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: result.2
                    ]
            )
            self.analytics.sendEvent(
                result.1,
                with:
                    [
                        AnalyticsKey.ParsingError: text
                    ])
        case .badDataFromSBOL(let httpCode):
            self.analytics.sendEvent(
                result.0,
                with:
                    [
                        AnalyticsKey.httpCode: httpCode
                    ]
            )
        case .unauthorizedClient(let httpCode):
            self.analytics.sendEvent(
                result.0,
                with:
                    [
                        AnalyticsKey.httpCode: httpCode,
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: result.2
                    ]
            )
        case .personalInfo:
            self.analytics.sendEvent(
                result.0,
                with:
                    [
                        AnalyticsKey.httpCode: StatusCode.errorSystem.rawValue,
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: result.2
                    ]
            )
        case let .errorWithErrorCode(number, httpCode):
            self.analytics.sendEvent(
                result.0,
                with:
                    [
                        AnalyticsKey.errorCode: number,
                        AnalyticsKey.httpCode: httpCode,
                        AnalyticsKey.view: result.2
                    ]
            )
        case .noCards:
            self.analytics.sendEvent(
                result.0,
                with:
                    [
                        AnalyticsKey.httpCode: StatusCode.errorSystem.rawValue,
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: result.2
                    ]
            )
        case .cancelled:
            self.analytics.sendEvent(
                result.0,
                with:
                    [
                        AnalyticsKey.httpCode: StatusCode.errorSystem.rawValue,
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: result.2
                    ]
            )
        case .timeOut(let httpCode):
            self.analytics.sendEvent(
                result.0,
                with:
                    [
                        AnalyticsKey.httpCode: httpCode,
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: result.2
                    ]
            )
        case .ssl(let httpCode):
            self.analytics.sendEvent(
                result.0,
                with:
                    [
                        AnalyticsKey.httpCode: httpCode,
                        AnalyticsKey.errorCode: Int64(-1),
                        AnalyticsKey.view: result.2
                    ]
            )
        case .bankAppNotFound:
            return
        }
    }
    
    private func parseAnaliticsType(type: AnaliticTypeRequest) -> (AnalyticsEvent,
                                                                          AnalyticsEvent,
                                                                          String) {
        switch type {
        case .otp(let type):
            let rqFail: AnalyticsEvent = type == .confirmOTP ?
                .RQFailConfirmOTP :
                .RQFailCreteOTP
            let rsFail: AnalyticsEvent = type == .confirmOTP ?
                .RSFailConfirmOTP :
                .RSFailCreteOTP
            let screen = AnlyticsScreenEvent.OtpVC.rawValue
            return (rqFail, rsFail, screen)
        case .auth(let type):
            let rqFail: AnalyticsEvent = type == .auth ?
                .RQFailAuth :
                .RQFailSessionId
            let rsFail: AnalyticsEvent = type == .auth ?
                .RSFailAuth :
                .RSFailSessionId
            let screen = type == .sessionId ?
            AnlyticsScreenEvent.AuthVC.rawValue :
            AnlyticsScreenEvent.PaymentVC.rawValue
            return (rqFail, rsFail, screen)
        case .bnpl:
            let rqFail: AnalyticsEvent = .RQFailBnpl
            let rsFail: AnalyticsEvent = .RSFailBnpl
            let screen = AnlyticsScreenEvent.PartPayVC.rawValue
            return (rqFail, rsFail, screen)
        case .payment(let type):
            let rqFail: AnalyticsEvent = type == .paymentOrder ?
                .RQFailPaymentOrder :
                .RQFailPaymentToken
            let rsFail: AnalyticsEvent = type == .paymentOrder ?
                .RSFailPaymentOrder :
                .RSFailPaymentToken
            let screen = AnlyticsScreenEvent.PaymentVC.rawValue
            return (rqFail, rsFail, screen)
        case .remote:
            let rqFail: AnalyticsEvent = .RQFailRemoteConfig
            let rsFail: AnalyticsEvent = .RSFailRemoteConfig
            let screen = AnlyticsScreenEvent.None.rawValue
            return (rqFail, rsFail, screen)
        case .listCards:
            let rqFail: AnalyticsEvent = .RQFailListCards
            let rsFail: AnalyticsEvent = .RSFailListCards
            let screen = AnlyticsScreenEvent.PaymentVC.rawValue
            return (rqFail, rsFail, screen)
        }
    }
}

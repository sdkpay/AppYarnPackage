//
//  AnalyticsManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 18.03.2024.
//

import UIKit

enum AnalyticsKey: String {
    case View
    case OrderNumber
    case MerchLogin
    case SessionId
    case ErrorCode
    case ParsingError
    case HttpCode
    case Permisson
    case BiZoneCode
    case State
    case Environment
    case Value
}

enum AnlyticsViewName: String {
    case NoActiveCardsView
    case HelpersView
    case PayView
    case BankAppView
    case PartPayView
    case ListCardView
    case ProfileView
    case BNPLView
    case AuthView
    case WebViewVC
    case OTPView
    case ConfirmView
    case StatusView
    case OtpReviewView
    case ReviewHintView
    case DenyView
    case DenyBlock
    case None
}

final class AnalyticsServiceManager: Assembly {
    
    var type = ObjectIdentifier(AnalyticsManager.self)
    
    func register(in locator: LocatorService) {
        let service: AnalyticsManager = DefaultAnalyticsManager(service: locator.resolve(),
                                                                authManager: locator.resolve(),
                                                                sdkManager: locator.resolve())
        locator.register(service: service)
    }
}

protocol AnalyticsManager: NSObject {
    
    func send(_ event: String, on view: AnlyticsViewName?, values: [AnalyticsKey: String])
    
    func sendRequestStarted(_ request: URLRequest)
    func sendRequestCompleted(_ target: TargetType,
                              response: URLResponse?,
                              error: Error?)
    func sendResponseDecoded(_ target: TargetType, response: URLResponse?)
    func sendResponseDecoded(_ target: TargetType, response: URLResponse?, with error: SDKError)
    
    func sendAppeared(view: ContentVC)
    func sendDisappeared(view: ContentVC)
}

extension AnalyticsManager {
    
    func send(_ event: String, on view: AnlyticsViewName? = nil, values: [AnalyticsKey: String] = [:]) {
        send(event, on: view, values: values)
    }
}

final class DefaultAnalyticsManager: NSObject, AnalyticsManager {
    
    private let service: AnalyticsService
    private let authManager: AuthManager
    private let sdkManager: SDKManager
    
    init(service: AnalyticsService,
         authManager: AuthManager,
         sdkManager: SDKManager) {
        self.service = service
        self.authManager = authManager
        self.sdkManager = sdkManager
    }
    
    func send(_ event: String, on view: AnlyticsViewName?, values: [AnalyticsKey: String]) {
        
        Task {
            var dict = values
    
            if let viewEvent = view?.rawValue {
                dict[.View] = viewEvent
            } else {
                dict[.View] = await getTopVCName().rawValue
            }
            addSessionParams(to: &dict)
            service.sendEvent(event, with: dict)
        }
    }

    private func addSessionParams(to dictionary: inout [AnalyticsKey: String]) {
        
        dictionary[.OrderNumber] = authManager.orderNumber
        dictionary[.SessionId] = authManager.sessionId
        dictionary[.MerchLogin] = sdkManager.authInfo?.merchantLogin
    }
}

extension DefaultAnalyticsManager {
    
    func sendRequestStarted(_ request: URLRequest) {
        
        let path = request.url?.lastPathComponent ?? ""
        
        Task {
            let viewName = await getTopVCName()
            
            send(EventBuilder().with(base: .RQ).with(value: MetricsValue(rawValue: path)).build(),
                 on: viewName)
        }
    }
    
    func sendRequestCompleted(_ target: TargetType,
                              response: URLResponse?,
                              error: Error?) {
        Task {
            let path = response?.url?.lastPathComponent ?? getLastComponent(target.path)
            let viewName = await getTopVCName()
            var analytics = [AnalyticsKey: String]()
            
            let event = EventBuilder()
                .with(base: .RQ)
                .with(value: MetricsValue(rawValue: path))
            
            var code = "None"
            
            if let response = response as? HTTPURLResponse {
                code = String(response.statusCode)
            } else if let error = error {
                code = "\(error._code) - \(error.localizedDescription)"
            }
            
            if code == "200" {
                event.with(state: .Good)
            } else {
                event.with(state: .Fail)
                analytics[.ErrorCode] = String(error?.sdkError.httpCode ?? 0)
                analytics[.ParsingError] = error?.sdkError.description
            }
            
            send(event.build(),
                 on: viewName,
                 values: analytics)
        }
    }
    
    func sendResponseDecoded(_ target: TargetType, response: URLResponse?) {
        
        Task {
            let path = response?.url?.lastPathComponent ?? getLastComponent(target.path)
            let viewName = await getTopVCName()
            let event = EventBuilder()
                .with(base: .RS)
                .with(value: MetricsValue(rawValue: path))
                .with(state: .Good)
                .build()
            
            send(event,
                 on: viewName)
        }
    }
    
    func sendResponseDecoded(_ target: TargetType, response: URLResponse?, with error: SDKError) {
        
        Task {
            guard error.represents(.failDecode) else { return }
            
            let path = response?.url?.lastPathComponent ?? getLastComponent(target.path)
            let viewName = await getTopVCName()
            let event = EventBuilder()
                .with(base: .RS)
                .with(value: MetricsValue(rawValue: path))
                .with(state: .Fail)
                .build()
            
            send(event,
                 on: viewName, 
                 values: [.ParsingError: error.description])
        }
    }
    
    private func getLastComponent(_ value: String) -> String {
        let host = "https://www.google.ru/" + value
        let lastComp = URL(string: host)?.lastPathComponent ?? "none"

        if lastComp.isEmpty {
            // Костыль для getIp
            return "getIp"
        }
        return lastComp
    }

    @MainActor
    private func getTopVCName() -> AnlyticsViewName {
        
        let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })

        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            guard let content = topController as? ContentVC else { return .None }
            
            return content.analyticsName
        } else {
            return .None
        }
    }
}

extension DefaultAnalyticsManager {
    
    func sendAppeared(view: ContentVC) {
        
        send(EventBuilder()
            .with(base: .LC)
            .with(value: MetricsValue(rawValue: view.analyticsName.rawValue))
            .with(postAction: .Appeared)
            .build(),
             on: view.analyticsName)
    }
    
    func sendDisappeared(view: ContentVC) {
        
        send(EventBuilder()
            .with(base: .LC)
            .with(value: MetricsValue(rawValue: view.analyticsName.rawValue))
            .with(postAction: .Disappeared)
            .build(),
             on: view.analyticsName)
    }
}

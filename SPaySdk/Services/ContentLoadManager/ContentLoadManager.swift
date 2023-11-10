//
//  ContentLoadManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 27.04.2023.
//

import Foundation

typealias ContentLoadType = (type: ContentType, priority: Priority)

final class ContentLoadManagerAssembly: Assembly {
    func register(in container: LocatorService) {
        container.register {
            let service: ContentLoadManager = DefaultContentLoadManager(userService: container.resolve(),
                                                                        featureToggleService: container.resolve(),
                                                                        partPayService: container.resolve())
            return service
        }
    }
}

enum Priority {
    case high
    case low
}

enum ContentType {
    case userData
    case bnplPlan
}

protocol ContentLoadManager {
    func load(contentTypes: [ContentLoadType]) async throws
    func load() async throws
}

final class DefaultContentLoadManager: ContentLoadManager {
    private let userService: UserService
    private let featureToggleService: FeatureToggleService
    private var partPayService: PartPayService
    
    private let group = DispatchGroup()
    
    init(userService: UserService,
         featureToggleService: FeatureToggleService,
         partPayService: PartPayService) {
        self.featureToggleService = featureToggleService
        self.partPayService = partPayService
        self.userService = userService
    }
    
    func load() async throws {
        var contentTypes: [ContentLoadType] = [
            (.userData, .high)
        ]
        if featureToggleService.isEnabled(.bnpl2) {
            contentTypes.append((.bnplPlan, .low))
        }
       try await load(contentTypes: contentTypes)
    }
    
    func load(contentTypes: [ContentLoadType]) async throws {
        
        var requestErrors: [(error: SDKError?, priority: Priority)] = []
        
        for type in contentTypes {
            
            do {
                try await self.loadContent(type.type)
            } catch {
                if let error = error as? SDKError {
                    requestErrors.append((error, type.priority))
                }
            }
        }
    
        for type in contentTypes {
            self.group.enter()
            self.loadContent(type.type) { error in
                requestErrors.append((error, type.priority))
                 self.group.leave()
            }
        }
        
        group.notify(queue: .main) {

            let error = requestErrors
                .compactMap({ $0 })
                .first(where: { $0.priority == .high })?
                .error

            completion(error)
        }
    }
    
    private func loadContent(_ type: ContentType) async throws {
        switch type {
        case .userData:
           try await userService.getUser()
        case .bnplPlan:
            try await partPayService.getBnplPlan()
        }
    }
}

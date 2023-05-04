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
    func load(contentTypes: [ContentLoadType],
              completion: @escaping (SDKError?) -> Void)
    func load(completion: @escaping (SDKError?) -> Void)
}

final class DefaultContentLoadManager: ContentLoadManager {
    private let userService: UserService
    private var partPayService: PartPayService
    
    private let group = DispatchGroup()
    
    init(userService: UserService,
         partPayService: PartPayService) {
        self.partPayService = partPayService
        self.userService = userService
    }
    
    func load(completion: @escaping (SDKError?) -> Void) {
        var contentTypes: [ContentLoadType] = [
            (.userData, .high)
        ]
        if partPayService.bnplplanEnabled {
            contentTypes.append((.bnplPlan, .low))
        }
        load(contentTypes: contentTypes, completion: completion)
    }
    
    func load(contentTypes: [ContentLoadType],
              completion: @escaping (SDKError?) -> Void) {
        var requestErrors: [(error: SDKError?, priority: Priority)] = []
    
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
    
    private func loadContent(_ type: ContentType,
                             completion: @escaping (SDKError?) -> Void) {
        switch type {
        case .userData:
            userService.getUser(completion: completion)
        case .bnplPlan:
            partPayService.getBnplPlan(completion: completion)
        }
    }
}

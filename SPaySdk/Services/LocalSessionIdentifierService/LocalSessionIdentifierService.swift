//
//  LocalSessionIdentifierService.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 03.07.2024.
//

import Foundation

final class LocalSessionIdentifierServiceAssembly: Assembly {
    
    var type = ObjectIdentifier(LocalSessionIdentifierService.self)
    
    func register(in container: LocatorService) {
        let service: LocalSessionIdentifierService = DefaultLocalSessionIdentifierService()
        container.register(service: service)
    }
}

protocol LocalSessionIdentifierService {
    
    var localSessionIdentifier: String? { get }
    func generateId()
}

final class DefaultLocalSessionIdentifierService: LocalSessionIdentifierService {
    
    private(set) var localSessionIdentifier: String?
    
    func generateId() {
        localSessionIdentifier = String.generateRandom(with: 12).uppercased()
    }
}

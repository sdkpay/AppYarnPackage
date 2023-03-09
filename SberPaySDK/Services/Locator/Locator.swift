//
//  Locator.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 25.01.2023.
//

protocol Assembly: AnyObject {
    func register(in container: LocatorService)
}

protocol LocatorService {
    func resolve<T>() -> T
    func register<T>(service: T) 
}

final class DefaultLocatorService: LocatorService {
    private lazy var services = [String: Any]()

    func register<T>(service: T) {
        let key = typeName(T.self)
        services[key] = service
        SBLogger.logLocatorRegister(key)
    }

    func resolve<T>() -> T {
        let key = typeName(T.self)
        if let result = services[key] as? T {
            SBLogger.logLocatorResolve(key)
            return result
        } else {
            fatalError("Cannot resolve dependency")
        }
    }
    
    private func typeName(_ some: Any) -> String {
        return (some is Any.Type) ? "\(some)" : "\(type(of: some))"
    }
}

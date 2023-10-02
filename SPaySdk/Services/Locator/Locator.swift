//
//  Locator.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 25.01.2023.
//

protocol Assembly: AnyObject {
    func register(in container: LocatorService)
}

protocol LocatorService {
    func resolve<T>(_ type: T.Type) -> T
    func resolve<T>() -> T
    func register<T>(service: T)
    func register<T>(reference: @escaping () -> T)
}

final class DefaultLocatorService: LocatorService {
    private var store = [ObjectIdentifier: ObjectRegistry]()
    
    enum ObjectRegistry {
      case instance(Any)
      case reference(() -> Any)

      func unwrap() -> Any {
        switch self {
        case let .instance(instance): return instance
        case let .reference(reference): return reference()
        }
      }
    }
    
    func register<T>(service instance: T) {
        let key = ObjectIdentifier(T.self)
        store[key] = .instance(instance)
        SBLogger.logLocatorRegister("\(type(of: T.self))")
    }
    
    func register<T>(reference: @escaping () -> T) {
        let key = ObjectIdentifier(T.self)
        store[key] = .reference(reference)
        SBLogger.logLocatorRegisterRef("\(type(of: T.self))")
    }

    func resolve<T>() -> T {
        let key = ObjectIdentifier(T.self)
        if let item = store[key],
           let instance = item.unwrap() as? T {
            switch item {
            case .reference: register(service: instance)
            default: break
            }
           SBLogger.logLocatorResolve("\(type(of: T.self))")
            return instance
        } else {
            preconditionFailure("Could not resolve service for \(type(of: T.self))")
        }
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        return resolve()
    }
}

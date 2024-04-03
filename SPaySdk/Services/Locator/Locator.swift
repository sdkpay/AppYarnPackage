//
//  Locator.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 25.01.2023.
//

protocol Assembly: AnyObject {
    
    var type: ObjectIdentifier { get set }
    func register(in container: LocatorService)
}

protocol LocatorService {
    func resolve<T>(_ type: T.Type) -> T
    func resolve<T>() -> T
    func register<T>(service: T)
    func register<T>(reference: @escaping () -> T)
    func remove(_ type: ObjectIdentifier)
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
    }
    
    func register<T>(reference: @escaping () -> T) {
        let key = ObjectIdentifier(T.self)
        store[key] = .reference(reference)
    }

    func resolve<T>() -> T {
        let key = ObjectIdentifier(T.self)
        if let item = store[key],
           let instance = item.unwrap() as? T {
            switch item {
            case .reference: register(service: instance)
            default: break
            }
            return instance
        } else {
            preconditionFailure("Could not resolve service for \(type(of: T.self))")
        }
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        return resolve()
    }
    
    func remove(_ type: ObjectIdentifier) {
        
        store.removeValue(forKey: type)
    }
    
    deinit {
        print("DEINIT")
    }
}

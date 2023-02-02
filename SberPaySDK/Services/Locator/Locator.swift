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
    }

    func resolve<T>() -> T {
        let key = typeName(T.self)
        // swiftlint:disable force_cast
        return services[key] as! T
        // swiftlint:enable force_cast
    }
    
    private func typeName(_ some: Any) -> String {
        return (some is Any.Type) ? "\(some)" : "\(type(of: some))"
    }
}

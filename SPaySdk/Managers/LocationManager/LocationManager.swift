//
//  LocationManager.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 02.02.2023.
//

import Foundation
import CoreLocation

final class LocationManagerAssembly: Assembly {
    
    var type = ObjectIdentifier(LocationManager.self)
    
    func register(in container: LocatorService) {
        container.register {
            let service: LocationManager = DefaultLocationManager()
            return service
        }
    }
}

protocol LocationManager {
    var locationEnabled: Bool { get }
    func requestLocation()
}

final class DefaultLocationManager: LocationManager {
    var locationEnabled: Bool {
        var locationAuthorizationStatus: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            locationAuthorizationStatus = locationManager.authorizationStatus
        } else {
            locationAuthorizationStatus = CLLocationManager.authorizationStatus()
        }
        return locationAuthorizationStatus == .authorizedWhenInUse || locationAuthorizationStatus == .authorizedAlways
    }
    
    private var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        return locationManager
    }()
    
    func requestLocation() {
        locationManager.requestLocation()
    }
}

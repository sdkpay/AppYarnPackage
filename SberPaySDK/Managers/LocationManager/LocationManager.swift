//
//  LocationManager.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 02.02.2023.
//

import Foundation
import CoreLocation

final class LocationManagerAssembly: Assembly {
    func register(in container: LocatorService) {
        let service: LocationManager = DefaultLocationManager()
        container.register(service: service)
    }
}

protocol LocationManager {
    var locationEnabled: Bool { get }
    func requestLocation()
}

final class DefaultLocationManager: LocationManager {
    private var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        return locationManager
    }()

    var locationEnabled: Bool {
        var locationAuthorizationStatus: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            locationAuthorizationStatus = locationManager.authorizationStatus
        } else {
            locationAuthorizationStatus = CLLocationManager.authorizationStatus()
        }
        return locationAuthorizationStatus == .authorizedWhenInUse || locationAuthorizationStatus == .authorizedAlways
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
}

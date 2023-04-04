//
//  NetworkMonitorManager.swift
//  SPaySdk
//
//  Created by Арсений on 31.03.2023.
//

import Network
import SystemConfiguration
import CoreTelephony

extension NWInterface.InterfaceType: CaseIterable {
    public static var allCases: [NWInterface.InterfaceType] = [
        .other,
        .wifi,
        .cellular,
        .loopback,
        .wiredEthernet
    ]
}

final class NetworkMonitorManager {
    
    private let queue = DispatchQueue(label: "NetworkConnectivityMonitor")
    private let monitor = NWPathMonitor()
        
    func startMonitoring() {
        monitor.pathUpdateHandler = { path in
            let currentConnectionType = NWInterface.InterfaceType.allCases.first(where: { path.usesInterfaceType($0) })
            guard let currentConnectionType else { return }
            self.printConnectionType(type: currentConnectionType)
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
    private func printConnectionType(type: NWInterface.InterfaceType) {
        var currentConnectionType = ""
        switch type {
        case .other:
            currentConnectionType = "other"
        case .wifi:
            currentConnectionType = "wifi"
        case .cellular:
            currentConnectionType = "cellular"
        case .wiredEthernet:
            currentConnectionType = "wiredEthernet"
        case .loopback:
            currentConnectionType = "loopback"
        @unknown default:
            fatalError("New NWInterface.InterfaceType has been added")
        }
        
        SBLogger.logCurrenConnectionType("\(currentConnectionType)")
    }
}

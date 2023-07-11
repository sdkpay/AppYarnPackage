//
//  RemoteCertificateService.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 10.07.2023.
//

import Foundation

final class RemoteCertificateServiceAssembly: Assembly {
    func register(in container: LocatorService) {
        let service: RemoteCertificateService = DefaultRemoteCertificateService(network: container.resolve(),
                                                                                buildSettings: container.resolve(),
                                                                                environmentManager: container.resolve())
        container.register(service: service)
    }
}

protocol RemoteCertificateService {
    func getCerts(completion: @escaping Action)
}

final class DefaultRemoteCertificateService: RemoteCertificateService {
    private let network: NetworkService
    private let buildSettings: BuildSettings
    private let environmentManager: EnvironmentManager
    private let optimizationManager = OptimizationCheсkerManager()
    
    private var localCertsKeys: [String] {
        UserDefaults.certKeys ?? []
    }
    
    init(network: NetworkService, buildSettings: BuildSettings, environmentManager: EnvironmentManager) {
        self.network = network
        self.buildSettings = buildSettings
        self.environmentManager = environmentManager
    }
    
    func getCerts(completion: @escaping Action) {

        guard localCertsKeys.isEmpty else {
            SBLogger.log(level: .debug(level: .network),
                         "#️⃣ Get local SSL certificates: \(UserDefaults.certKeys?.json ?? "none")")
            CertificateValidator.addPublicKeys(localCertsKeys)
            completion()
            return
        }
        
        var target: TargetType
        
        if environmentManager.environment != .prod {
            target = CertsTarget.getCertsSandbox
        }
        
        switch buildSettings.networkState {
        case .Prom:
            target = CertsTarget.getCertsProm
        case .Ift:
            target = CertsTarget.getCertsIft
        case .Psi:
            target = CertsTarget.getCertsPsi
        case .Local, .Mocker:
            target = CertsTarget.getCertsSandbox
        }
    
        network.request(target,
                        to: CertsModel.self,
                        host: .cers) { result in
            completion()
            switch result {
            case .success(let result):
                UserDefaults.certKeys = result.certKeys
                CertificateValidator.addPublicKeys(result.certKeys)
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
}

//
//  CertificateValidator.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 05.04.2023.
//

import Foundation

private extension String {
    static let sslOff = "#️⃣ SSL pinning отключен"
    static let sslSuccess = "#️⃣ SSL pinning прошел успешно"
    static let sslErrorNoSeverCerts = "🔺 Ошибка SSL pinning - не удалось найти сертификаты на сервер"
    static let sslErrorBadSerts = "🔺 Ошибка SSL pinning - сертификаты не совпадают"
}

enum CertificateValidator {
    private static var certificates: [Data] {
        Certificates.allCases.compactMap({ $0.data })
    }
    
    static func validate(challenge: URLAuthenticationChallenge,
                         completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if !BuildSettings.shared.ssl {
            SBLogger.log(level: .debug(level: .network), .sslOff)
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        guard let trust = challenge.protectionSpace.serverTrust, SecTrustGetCertificateCount(trust) > 0 else {
            SBLogger.log(level: .debug(level: .network), .sslErrorNoSeverCerts)
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
    
        if let serverCertificate = SecTrustGetCertificateAtIndex(trust, 0) {
            let serverCertificateData = SecCertificateCopyData(serverCertificate) as Data
            if certificates.contains(serverCertificateData) {
                SBLogger.log(level: .debug(level: .network), .sslSuccess)
                completionHandler(.useCredential, URLCredential(trust: trust))
                return
            }
        }
        
        completionHandler(.cancelAuthenticationChallenge, nil)
        SBLogger.log(level: .debug(level: .network), .sslErrorBadSerts)
    }
}

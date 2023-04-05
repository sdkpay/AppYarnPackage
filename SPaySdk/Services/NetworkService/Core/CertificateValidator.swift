//
//  CertificateValidator.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 05.04.2023.
//

import Foundation

enum CertificateValidator {
    private static var sertificates: [Data] {
        Certificates.allCases.compactMap({ $0.data })
    }
    
    static func validate(challenge: URLAuthenticationChallenge,
                         completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if !BuildSettings.shared.ssl {
            SBLogger.log(level: .debug(level: .network), "#️⃣ SSL pinning отключен")
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        guard let trust = challenge.protectionSpace.serverTrust, SecTrustGetCertificateCount(trust) > 0 else {
            SBLogger.log(level: .debug(level: .network), "🔺 Ошибка SSL pinning")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
    
        if let serverCertificate = SecTrustGetCertificateAtIndex(trust, 0) {
            let serverCertificateData = SecCertificateCopyData(serverCertificate) as Data
            if sertificates.contains(serverCertificateData) {
                SBLogger.log(level: .debug(level: .network), "#️⃣ SSL pinning прошел успешно")
                completionHandler(.useCredential, URLCredential(trust: trust))
                return
            }
        }
        
        completionHandler(.cancelAuthenticationChallenge, nil)
        SBLogger.log(level: .debug(level: .network), "🔺 Ошибка SSL pinning")
    }
}

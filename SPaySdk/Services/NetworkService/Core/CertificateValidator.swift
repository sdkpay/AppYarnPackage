//
//  CertificateValidator.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 05.04.2023.
//

import Foundation
import CryptoKit

private extension String {
    static let sslOff = "#️⃣ SSL pinning отключен"
    static let sslSuccess = "#️⃣ SSL pinning прошел успешно"
    static let sslNoSeverCerts = "#️⃣ SSL pinning - протекция сервера не найдена"
    static let sslErrorNoSeverCerts = "🔺 Ошибка SSL pinning - не удалось найти сертификаты на сервере"
    static let sslErrorNoLocalCerts = "🔺 Ошибка SSL pinning - не удалось найти локальные сертификаты"
    static let sslErrorBadSerts = "🔺 Ошибка SSL pinning - сертификаты не совпадают"
}

enum CertificateValidator {

    private static var certificates: [Data] {
        Certificates.allCases.compactMap({ $0.data })
    }
    
    static func validate(defaultHandling: Bool,
                         challenge: URLAuthenticationChallenge,
                         completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if defaultHandling {
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

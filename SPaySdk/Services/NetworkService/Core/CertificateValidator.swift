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

    private static var serverPublicKeysHashes: [String] = []
    
    static func addPublicKeys(_ keys: [String]) {
        keys.forEach({ addPublicKey($0) })
    }
    
    private static func addPublicKey(_ key: String) {
        serverPublicKeysHashes.append(key)
    }
    
    private static let rsa2048Asn1Header: [UInt8] = [
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
    ]
    
    static func validate(defaultHandling: Bool,
                         challenge: URLAuthenticationChallenge,
                         completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        if defaultHandling {
            SBLogger.log(level: .debug(level: .network), .sslOff)
            completionHandler(.performDefaultHandling, nil)
        }

        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else {
            SBLogger.log(level: .debug(level: .network), .sslNoSeverCerts)
            completionHandler(.performDefaultHandling, nil)
            return
        }

        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            SBLogger.log(level: .debug(level: .network), .sslErrorNoSeverCerts)
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        var secresult: CFError?
        let certTrusted = !SecTrustEvaluateWithError(serverTrust, &secresult)
        let certCount = SecTrustGetCertificateCount(serverTrust)

        guard certTrusted && certCount > 0 else {
            SBLogger.log(level: .debug(level: .network), .sslNoSeverCerts)
            completionHandler(.performDefaultHandling, nil)
            return
        }

        guard !serverPublicKeysHashes.isEmpty else {
            SBLogger.log(level: .debug(level: .network), .sslErrorNoLocalCerts)
            SBLogger.log(level: .debug(level: .network), .sslNoSeverCerts)
            return
        }

        if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
            if let publicKey = SecCertificateCopyKey(serverCertificate) {

                var error: Unmanaged<CFError>?

                if let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? {
                    var keyWithHeader = Data(rsa2048Asn1Header)
                    keyWithHeader.append(publicKeyData)
                    var digestString = ""
                    if #available(iOS 13.0, *) {
                        let digest = SHA256.hash(data: keyWithHeader)
                        digestString = Data(digest).base64EncodedString()
                    }
                    if serverPublicKeysHashes.contains(digestString) {
                        SBLogger.log(level: .debug(level: .network), .sslSuccess)
                        completionHandler(.useCredential, URLCredential(trust: serverTrust))
                        return
                    } else {
                        completionHandler(.cancelAuthenticationChallenge, nil)
                        SBLogger.log(level: .debug(level: .network), .sslErrorBadSerts)
                        return
                    }
                }
            }
        }

        SBLogger.log(level: .debug(level: .network), .sslErrorNoSeverCerts)
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}

//
//  Certificates.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 05.04.2023.
//

import Foundation

enum Certificates: String, CaseIterable {
    case psi = "psi.spaymentsplus.ru"
    case ift = "ift.gate1.spaymentsplus.ru"
    case cms = "cms-res"

    var data: Data? {
        getCertificate(self.rawValue)
    }
    
    private func getCertificate(_ filename: String) -> Data? {
        guard let path = Bundle(for: SPay.self).path(forResource: filename,
                                                     ofType: "der")
        else { return nil }
        return NSData(contentsOfFile: path) as? Data
    }
}

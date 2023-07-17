//
//  Certificates.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 05.04.2023.
//

import Foundation

enum CertificatesKeys: String, CaseIterable {
    case subCA = "c5vrLWsonReRbgbtO/d8quvwiejpedqth2k3GA3xB2U="
    case cms = "8Zfp1LAJpCyXmDDrT6O7fcNWRIIJnRcUExv17jA50Wc="

    static var allValues: [String] {
        self.allCases.map { $0.rawValue }
    }
}

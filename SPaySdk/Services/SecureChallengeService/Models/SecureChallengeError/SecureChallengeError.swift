//
//  SecureChallengeError.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 25.11.2023.
//

import Foundation

struct SecureChallengeError: Error, LocalizedError {

    let fraudMonСheckResult: FraudMonСheckResult
    
    init?(from error: SDKError) {
        
        guard let data = error.data else { return nil }
        
        let decoder = JSONDecoder()
        
        guard let decodedData = try? decoder.decode(FraudMonСheckError.self, from: data) else { return nil }
        fraudMonСheckResult = decodedData.fraudMonСheckResult
    }
}

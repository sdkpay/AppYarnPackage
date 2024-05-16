//
//  UIImage+base64.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 27.03.2023.
//

import UIKit

extension UIImage {
    
    convenience init?(base64: String) {
        
        guard let imageData = Data(base64Encoded: base64) else { return nil }
        self.init(data: imageData)
    }
    
    convenience init?(jsonPath: URL) {
        
        guard let string = try? Data(contentsOf: jsonPath).decode(to: String.self) else { return nil }
        self.init(base64: string)
    }
}

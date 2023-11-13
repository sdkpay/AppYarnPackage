//
//  PaymentCollectionViewLayoutManager.swift
//  Crypto
//
//  Created by Ипатов Александр Станиславович on 12.10.2023.
//

import UIKit

extension CGFloat {
    
    static let interSectionSpacing = 16.0
}

enum PaymentCollectionViewLayoutManager {
    
    static func create(with sectionProvider: @escaping UICollectionViewCompositionalLayoutSectionProvider) -> UICollectionViewLayout {
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = .interSectionSpacing
        
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: config)
    }
}

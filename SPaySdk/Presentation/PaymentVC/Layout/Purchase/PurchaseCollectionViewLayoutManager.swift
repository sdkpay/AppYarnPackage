//
//  PurchaseCollectionViewLayoutManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 08.12.2023.
//

import Foundation

enum PurchaseCollectionViewLayoutManager {
    
    static func create(with sectionProvider: @escaping UICollectionViewCompositionalLayoutSectionProvider) -> UICollectionViewLayout {
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: config)
    }
}

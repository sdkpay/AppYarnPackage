//
//  CardCollectionViewLayoutManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 02.04.2024.
//

import UIKit


enum CardCollectionViewLayoutManager {
    
    static func create(with sectionProvider: @escaping UICollectionViewCompositionalLayoutSectionProvider) -> UICollectionViewLayout {
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: config)
    }
}


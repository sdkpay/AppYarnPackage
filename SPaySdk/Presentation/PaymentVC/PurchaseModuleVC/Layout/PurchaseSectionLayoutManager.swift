//
//  PurchaseSectionLayoutManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 08.12.2023.
//

import UIKit

private extension CGFloat {
    
    enum HeightConstants {
    
        static let height: CGFloat = 68
    }
}

enum PurchaseSectionLayoutManager {
    
    static func getSectionLayout(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        
        return blockSection
    }
    
    private static var blockSection: NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .absolute(.HeightConstants.height))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(.HeightConstants.height))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered

        return section
    }
}

//
//  CardSectionLayoutManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 02.04.2024.
//

import UIKit

private extension CGFloat {
    
    static let groupMargin: CGFloat = 16
    
    enum HeightConstants {
    
        static let height: CGFloat = 56
    }
}

enum CardSectionLayoutManager {
    
    static func getSectionLayout(
        layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
            
            return blockSection
        }

    private static var blockSection: NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }
}

//
//  PaymentSectionLayoutManager.swift
//  Crypto
//
//  Created by Ипатов Александр Станиславович on 12.10.2023.
//

import UIKit

private extension CGFloat {
    
    static let groupMargin: CGFloat = 16
    
    enum HeightConstants {
    
        static let height: CGFloat = 56
    }
    
    enum ActionConstants {
        
        static let width: CGFloat = 80
        static let height: CGFloat = 95
        static let margin: CGFloat = 3
    }
    
    enum AssetConstants {
        
        static let width: CGFloat = 160
        static let height: CGFloat = 160
        static let margin: CGFloat = 4
    }
}

enum PaymentSectionLayoutManager {
    
    static func getSectionLayout(_ section: PaymentSection,
                                 featureCount: Int,
                                 layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        
        switch section {
        case .features:
            return featureCount > 1 ? squareSection : blockSection
        case .card:
            return blockSection
        }
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
    
    private static var squareSection: NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(.AssetConstants.width),
                                               heightDimension: .estimated(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        group.contentInsets = .init(top: .zero,
                                    leading: .AssetConstants.margin,
                                    bottom: .zero,
                                    trailing: .AssetConstants.margin)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: .zero,
                                      leading: .groupMargin,
                                      bottom: .zero,
                                      trailing: .groupMargin)
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }
}

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
}

enum PaymentSectionLayoutManager {
    
    static func getSectionLayout(_ section: PaymentSection,
                                 featureCount: Int,
                                 layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        
        switch section {
        case .features:
            switch featureCount {
            case 0...1:
                return blockSection
            case 1...2:
                return squareSection
            default:
                return longSection
            }
        case .card:
            return blockSection
        }
    }
    
    private static var longSection: NSCollectionLayoutSection {
        
        let spacing: CGFloat = 4
        
        let longtemSize = NSCollectionLayoutSize(
                  widthDimension: .fractionalWidth(0.7),
                  heightDimension: .fractionalHeight(1.0))
        
        let longItem = NSCollectionLayoutItem(layoutSize: longtemSize)
        longItem.contentInsets = .init(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
        
        let itemSize = NSCollectionLayoutSize(
                  widthDimension: .fractionalWidth(0.5),
                  heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
        
        let groupSize = NSCollectionLayoutSize(
                  widthDimension: .estimated(1.0),
                  heightDimension: .fractionalWidth(0.5))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [longItem, item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        return section
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
        
        let spacing: CGFloat = 4
        
        let itemSize = NSCollectionLayoutSize(
                  widthDimension: .fractionalWidth(0.5),
                  heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
        
        let groupSize = NSCollectionLayoutSize(
                  widthDimension: .fractionalWidth(1.0),
                  heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }
}

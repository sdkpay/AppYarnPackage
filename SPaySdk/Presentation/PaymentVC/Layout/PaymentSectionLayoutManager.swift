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
    
    enum BalanceConstants {
    
        static let height: CGFloat = 106
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
    
    enum HistoryConstants {

        static let height: CGFloat = 72
    }
}

enum PaymentSectionLayoutManager {
    
    static func getSectionLayout(_ section: PaymentSection,
                                 layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        
        switch section {
        case .card: return blockSection
        case .features: return squareSection
        }
    }

    private static var blockSection: NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(.BalanceConstants.height))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = .init(top: 8.0, leading: 0, bottom: 8.0, trailing: 0)
        
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

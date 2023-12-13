//
//  UICollectionView.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 09.12.2023.
//

import UIKit

extension UICollectionView {
    
    static func config<T: SelfReusable & SelfConfigCell, U: AbstractCellModel>(collectionView: UICollectionView,
                                                                               cellType: T.Type,
                                                                               with model: U,
                                                                               fot indexPath: IndexPath) -> T? {
       
       guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseId, for: indexPath) as? T else { return nil }
       cell.config(with: model)
       return cell
   }
}

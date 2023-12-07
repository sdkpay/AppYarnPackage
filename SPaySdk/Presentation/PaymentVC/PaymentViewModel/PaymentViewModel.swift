//
//  PaymentViewModel.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 05.12.2023.
//

import Foundation

protocol PaymentViewModel {
    
    var needHint: Bool { get }
    var hintText: String { get }
    var featureCount: Int { get }
    var payButton: Bool { get }
    func identifiresForSection(_ section: PaymentSection) -> [Int]
    func model(for indexPath: IndexPath) -> AbstractCellModel?
}

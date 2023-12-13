//
//  PaymentPresenting.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 05.12.2023.
//

import Foundation

protocol PaymentViewModel {
    
    var needHint: Bool { get }
    var hintText: String { get }
    var featureCount: Int { get }
    var screenHeight: ScreenHeightState { get }
    var payButton: Bool { get }
    var purchaseInfoText: String? { get }
    var presenter: PaymentPresentingInput? { get set }
    func identifiresForPurchaseSection() -> [Int]
    func identifiresForSection(_ section: PaymentSection) -> [Int]
    func model(for indexPath: IndexPath) -> AbstractCellModel?
    func didSelectPaymentItem(at indexPath: IndexPath)
}

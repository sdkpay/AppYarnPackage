//
//  HintsModulePresenting.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 04.03.2024.
//

import Foundation

protocol HintsModulePresenting: NSObject {
    
    func viewDidLoad()
    
    var view: (IHintsModuleVC & ModuleVC)? { get set }
}

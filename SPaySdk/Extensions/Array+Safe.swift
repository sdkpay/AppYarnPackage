//
//  Array+Safe.swift
//  SPaySdk
//
//  Created by Арсений on 19.04.2023.
//

import UIKit

extension Array {
    subscript(safe index: Index) -> Element? {
        return self.indices ~= index ? self[index] : nil
    }
}

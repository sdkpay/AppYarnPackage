//
//  String+Localized.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 21.11.2022.
//

import UIKit

extension String {
    init(stringLiteral value: StringLiteralType) {
        self = NSLocalizedString(value, bundle: Bundle.sdkBundle, comment: "")
    }
}

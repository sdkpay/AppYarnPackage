//
//  UIImage+AssetName.swift
//  SberPaySDK
//
//  Created by Арсений on 07.03.2023.
//

import UIKit

extension UIImage {
    var assetName: String? {
        imageAsset?.value(forKey: "assetName") as? String
    }
}

//
//  UIImageView+Download.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 21.03.2023.
//

import UIKit

extension UIImageView {
    func downloadImage(from url: String?,
                       placeholder: UIImage? = nil,
                       shimmer: Bool = true) {
        self.shimmer(shimmer)
        ImageDownloader.shared.downloadImage(with: url,
                                             completionHandler: { image, _ in
            self.shimmer(false)
            self.image = image
        }, placeholderImage: placeholder)
    }
}

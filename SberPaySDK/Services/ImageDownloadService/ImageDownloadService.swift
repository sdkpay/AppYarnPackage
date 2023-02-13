//
//  ImageDownloadService.swift
//  SberPaySDK
//
//  Created by Alexander Ipatov on 13.02.2023.
//

import UIKit

final class ImageDownloadService {
    static let shared = ImageDownloadService()

    private var cachedImages: [String: UIImage]
    private var imagesDownloadTasks: [String: URLSessionDataTask]
    private let serialQueueForImages = DispatchQueue(label: "images.queue", attributes: .concurrent)
    private let serialQueueForDataTasks = DispatchQueue(label: "dataTasks.queue", attributes: .concurrent)

    private init() {
        cachedImages = [:]
        imagesDownloadTasks = [:]
    }

    func downloadImage(with imageUrlString: String?,
                       completionHandler: @escaping (UIImage?, Bool) -> Void,
                       placeholderImage: UIImage?) {

        guard let imageUrlString = imageUrlString else {
            completionHandler(placeholderImage, true)
            return
        }

        if let image = getCachedImageFrom(urlString: imageUrlString) {
            completionHandler(image, true)
        } else {
            guard let url = URL(string: imageUrlString) else {
                completionHandler(placeholderImage, true)
                return
            }

            if getDataTaskFrom(urlString: imageUrlString) != nil {
                return
            }

            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data else {
                    return
                }
                if error != nil {
                    DispatchQueue.main.async {
                        completionHandler(placeholderImage, true)
                    }
                    return
                }
                let image = UIImage(data: data)
                self.serialQueueForImages.sync(flags: .barrier) {
                    self.cachedImages[imageUrlString] = image
                }
                _ = self.serialQueueForDataTasks.sync(flags: .barrier) {
                    self.imagesDownloadTasks.removeValue(forKey: imageUrlString)
                }
                DispatchQueue.main.async {
                    completionHandler(image, false)
                }
            }
            self.serialQueueForDataTasks.sync(flags: .barrier) {
                imagesDownloadTasks[imageUrlString] = task
            }
            task.resume()
        }
    }

    private func cancelPreviousTask(with urlString: String?) {
        if let urlString = urlString, let task = getDataTaskFrom(urlString: urlString) {
            task.cancel()
            _ = serialQueueForDataTasks.sync(flags: .barrier) {
                imagesDownloadTasks.removeValue(forKey: urlString)
            }
        }
    }

    private func getCachedImageFrom(urlString: String) -> UIImage? {
        serialQueueForImages.sync {
            return cachedImages[urlString]
        }
    }

    private func getDataTaskFrom(urlString: String) -> URLSessionTask? {
        serialQueueForDataTasks.sync {
            return imagesDownloadTasks[urlString]
        }
    }
}

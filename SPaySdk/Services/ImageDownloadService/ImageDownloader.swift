//
//  ImageDownloader.swift
//  SPaySdk
//
//  Created by Alexander Ipatov on 13.02.2023.
//

import UIKit

enum ImageDownloaderError {
    case urlIsNil
    case invalidURL
    case dataIsNil
    case imageNotCreated
    case networkError(Error)
}

final class ImageDownloader: NSObject {
    static let shared = ImageDownloader()

    private var session: URLSession?
    private var cachedImages = [String: UIImage]()
    private var imagesDownloadTasks = [String: URLSessionDataTask]()
    private let serialQueueForImages = DispatchQueue(label: "images.queue", attributes: .concurrent)
    private let serialQueueForDataTasks = DispatchQueue(label: "dataTasks.queue", attributes: .concurrent)

    override init() {
        super.init()
        session = URLSession(configuration: .default,
                             delegate: self,
                             delegateQueue: nil)
        SBLogger.log(.start(obj: self))
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }

    func downloadImage(with imageUrlString: String?,
                       completionHandler: @escaping (UIImage?, Bool) -> Void,
                       placeholderImage: UIImage?) {

        guard let imageUrlString = imageUrlString else {
            SBLogger.logDownloadImageWithError(with: .urlIsNil,
                                               placeholder: placeholderImage)
            completionHandler(placeholderImage, true)
            return
        }
        
        SBLogger.logStartDownloadingImage(with: imageUrlString)

        if let image = getCachedImageFrom(urlString: imageUrlString) {
            SBLogger.logDownloadImageFromCache(with: imageUrlString)
            completionHandler(image, true)
        } else {
            guard let url = URL(string: imageUrlString) else {
                SBLogger.logDownloadImageWithError(with: .invalidURL,
                                                   urlString: imageUrlString,
                                                   placeholder: placeholderImage)
                completionHandler(placeholderImage, true)
                return
            }

            let task = session?.dataTask(with: url) { data, _, error in
                guard let data = data else {
                    SBLogger.logDownloadImageWithError(with: .dataIsNil,
                                                       urlString: imageUrlString,
                                                       placeholder: placeholderImage)
                    DispatchQueue.main.async {
                        completionHandler(placeholderImage, true)
                    }
                    return
                }
                if let error = error {
                    SBLogger.logDownloadImageWithError(with: .networkError(error),
                                                       urlString: imageUrlString,
                                                       placeholder: placeholderImage)
                    DispatchQueue.main.async {
                        completionHandler(placeholderImage, true)
                    }
                    return
                }
                guard let image = UIImage(data: data) else {
                    SBLogger.logDownloadImageWithError(with: .imageNotCreated,
                                                       urlString: imageUrlString,
                                                       placeholder: placeholderImage)
                    DispatchQueue.main.async {
                        completionHandler(placeholderImage, true)
                    }
                    return
                }
                self.serialQueueForImages.sync(flags: .barrier) {
                    self.cachedImages[imageUrlString] = image
                }
                _ = self.serialQueueForDataTasks.sync(flags: .barrier) {
                    self.imagesDownloadTasks.removeValue(forKey: imageUrlString)
                }
                
                DispatchQueue.main.async {
                    SBLogger.logDownloadImageWithSuccess(with: imageUrlString)
                    completionHandler(image, false)
                }
            }
            self.serialQueueForDataTasks.sync(flags: .barrier) {
                imagesDownloadTasks[imageUrlString] = task
            }
            task?.resume()
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

extension ImageDownloader: URLSessionDelegate {
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        CertificateValidator.validate(challenge: challenge, completionHandler: completionHandler)
    }
}

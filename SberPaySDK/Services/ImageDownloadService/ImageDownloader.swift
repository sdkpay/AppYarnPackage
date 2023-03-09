//
//  ImageDownloader.swift
//  SberPaySDK
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
    
    private lazy var certificate: Data? = {
        guard let fileDer = Bundle(for: SBPay.self).path(forResource: "cms-res",
                                                         ofType: "der")
        else { return nil }
        return NSData(contentsOfFile: fileDer) as? Data
    }()
    
    override init() {
        super.init()
        session = URLSession(configuration: .default,
                             delegate: self,
                             delegateQueue: nil)
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

            if getDataTaskFrom(urlString: imageUrlString) != nil {
                return
            }

            let task = session?.dataTask(with: url) { data, response, error in
                guard let data = data else {
                    SBLogger.logDownloadImageWithError(with: .dataIsNil,
                                                       urlString: imageUrlString,
                                                       placeholder: placeholderImage)
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
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                    let serverCertificateData = SecCertificateCopyData(serverCertificate)
                    let data = CFDataGetBytePtr(serverCertificateData)
                    let size = CFDataGetLength(serverCertificateData)
                    let certFromHost = NSData(bytes: data, length: size)
                    if let localCert = certificate,
                       certFromHost.isEqual(to: localCert) {
                        completionHandler(.useCredential,
                                          URLCredential(trust: serverTrust))
                        return
                    } else {
                        completionHandler(.cancelAuthenticationChallenge, nil)
                        return
                    }
                }
            }
        }
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}

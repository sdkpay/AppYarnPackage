//
//  WebViewPresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 25.04.2023.
//

import UIKit

protocol WebViewPresenting {
    func viewDidLoad()
    func backButtonTapped()
    func shareButtonTapped()
}

final class WebViewPresenter: WebViewPresenting {
    private let url: String
    private let title: String
    
    weak var view: (IWebViewVC & ContentVC)?
    
    init(with url: String, title: String) {
        self.url = url
        self.title = title
    }
    
    func viewDidLoad() {
        setupWebView()
        view?.setTitle(text: title)
    }
    
    func backButtonTapped() {
        view?.contentNavigationController?.popViewController(animated: true)
    }
    
    func shareButtonTapped() {
        shareUrlAddress()
    }
    
    private func setupWebView() {
        guard let url = URL(string: url) else { return }
        view?.goTo(to: url)
    }
    
    private func shareUrlAddress() {
        DispatchQueue.global(qos: .userInteractive).async {
            guard let url = URL(string: self.url) else { return }
            let text = self.title
            let activity = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
            DispatchQueue.main.async {
                self.view?.present(activity, animated: true, completion: nil)
            }
        }
    }
}

//
//  WebViewPresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 25.04.2023.
//

import UIKit

protocol WebViewPresenting {
    func backButtonTapped()
    func viewDidLoad()
    func shareButtonTapped()
    func webTitle(_ title: String?)
}

private extension String {
    static let openTitleTag = "<title>"
    static let closeTitleTag = "</title>"
}

final class WebViewPresenter: WebViewPresenting {
    private let url: String
    @UserDefault(key: .offerTitle, defaultValue: nil)
    private var title: String?
    private let analytics: AnalyticsManager
    
    weak var view: (IWebViewVC & ContentVC)?
    
    init(with url: String,
         analytics: AnalyticsManager) {
        self.url = url
        self.analytics = analytics
    }
    
    func viewDidLoad() {
        setupWebView()
    }
    
    @MainActor
    func backButtonTapped() {
        analytics.send(EventBuilder()
            .with(base: .Touch)
            .with(value: .back)
            .build(), on: view?.analyticsName ?? .None)
        view?.contentNavigationController?.popViewController(animated: true)
    }
    
    func shareButtonTapped() {
        analytics.send(EventBuilder()
            .with(base: .Touch)
            .with(value: MetricsValue(rawValue: "Share"))
            .build(), on: view?.analyticsName ?? .None)
        shareUrlAddress()
    }

    private func setupWebView() {
        guard let url = URL(string: url) else { return }
        view?.goTo(to: url)
    }

    func webTitle(_ title: String?) {
        if self.title != title {
            self.title = title
        }
        view?.setTitle(text: title ?? "")
    }
    
    private func shareUrlAddress() {
        DispatchQueue.global(qos: .userInteractive).async {
            guard let url = URL(string: self.url) else { return }
            let text = self.title ?? ""
            let activity = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
            DispatchQueue.main.async {
                self.view?.present(activity, animated: true, completion: nil)
            }
        }
    }
}

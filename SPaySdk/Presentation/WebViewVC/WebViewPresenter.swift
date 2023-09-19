//
//  WebViewPresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 25.04.2023.
//

import UIKit

protocol WebViewPresenting {
    func viewDidLoad()
    func viewDidAppear()
    func backButtonTapped()
    func viewDidDisappear()
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
    private let analitics: AnalyticsService
    
    weak var view: (IWebViewVC & ContentVC)?
    
    init(with url: String,
         analitics: AnalyticsService) {
        self.url = url
        self.analitics = analitics
    }
    
    func viewDidLoad() {
        setupWebView()
    }
    
    func backButtonTapped() {
        view?.contentNavigationController?.popViewController(animated: true)
    }
    
    func shareButtonTapped() {
        shareUrlAddress()
    }
    
    func viewDidAppear() {
        analitics.sendEvent(.LCWebViewAppeared)
    }
    
    func viewDidDisappear() {
        analitics.sendEvent(.LCWebViewDisappeared)
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
        analitics.sendEvent(.TouchShare)
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

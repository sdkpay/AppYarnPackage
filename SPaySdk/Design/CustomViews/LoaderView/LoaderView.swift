//
//  LoaderView.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 04.05.2023.
//

import UIKit

protocol Loadable where Self: UIView {
    func startLoading(with text: String?)
    func stopLoading()
}

extension Loadable {
    func startLoading(with text: String? = nil) {
        let loadView = LoadingView(with: text)
        loadView
            .add(toSuperview: self)
            .touchEdge(.left, toSuperviewEdge: .left)
            .touchEdge(.right, toSuperviewEdge: .right)
            .touchEdge(.bottom, toSuperviewEdge: .bottom)
            .touchEdge(.top, toSuperviewEdge: .top)
        
        loadView.show()
    }
    
    func stopLoading() {
        let loadingView = subviews.first(where: { $0 is LoadingView })
        loadingView?.removeFromSuperview()
    }
}

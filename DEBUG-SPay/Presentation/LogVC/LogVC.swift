//
//  LogVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 30.03.2023.
//

import UIKit
import QuickLook

final class LogVC: QLPreviewController, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    
    private let url: URL
    private let completion: Action
    
    init(with url: URL, 
         completion: @escaping Action) {
        self.url = url
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        delegate = self
        dataSource = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        completion()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        url as QLPreviewItem
    }
}

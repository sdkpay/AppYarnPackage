//
//  StatusVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 01.12.2023.
//

import UIKit
import SPaySdkDEBUG

final class StatusVC: UIViewController {
    
    private let values: ConfigValues
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private lazy var sPayButton: SBPButton = {
        let view = SBPButton()
        view.tapAction = {
            self.autoPay()
        }
        return view
    }()
    
    private lazy var labelStatus: UILabel = {
       let view = UILabel()
        view.text = "Статусник"
        view.font = .systemFont(ofSize: 36)
        view.textColor = .darkGray
        return view
    }()
    
    init(values: ConfigValues) {
        self.values = values
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func autoPay() {
        let request = SBankInvoicePaymentRequest(merchantLogin: values.merchantLogin,
                                                 bankInvoiceId: values.orderId ?? "",
                                                 orderNumber: "12",
                                                 redirectUri: "sdknbzrxocne://spay",
                                                 apiKey: values.apiKey)
        SPay.payWithBankInvoiceId(with: self, paymentRequest: request) { state, info in
            switch state {
            case .success:
                self.showResult(title: "Отдали мерчу success", message: info)
            case .waiting:
                self.showResult(title: "Отдали мерчу waiting", message: info)
            case .error:
                self.showResult(title: "Отдали мерчу error", message: info)
            case .cancel:
                self.showResult(title: "Отдали мерчу cancel", message: info)
            @unknown default:
                self.showResult(title: "Отдали мерчу @unknown default", message: info)
            }
        }
    }
    
    private func showResult(title: String, message: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(vc, animated: true)
        }
    }
    
    private func setupUI() {
        self.view.backgroundColor = .white
        
        labelStatus
            .add(toSuperview: view)
            .centerInSuperview()
        
        if SPay.isReadyForSPay {
            view.addSubview(sPayButton)
            sPayButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                sPayButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                    constant: 16),
                sPayButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                     constant: -16),
                sPayButton.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                   constant: -40)
            ])
        }
    }
}

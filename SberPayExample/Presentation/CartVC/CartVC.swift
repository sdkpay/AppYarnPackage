//
//  CartVC.swift
//  SberPay
//
//  Created by Alexander Ipatov on 07.11.2022.
//

import UIKit
import SPaySdkDEBUG

extension CGFloat {
    static let paymentHeight = 200.0
    static let margin = 20.0
    static let bottomMargin = 50.0
}

final class CartVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let values: ConfigValues
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.separatorStyle = .none
        view.backgroundColor = .white
        view.register(CartCell.self, forCellReuseIdentifier: CartCell.reuseID)
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    private lazy var paymentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var totalCostLabel: UILabel = {
        let view = UILabel()
        view.text = "\(values.cost ?? "") p"
        view.textColor = .black
        return view
    }()
    
    private lazy var totalCostNameLabel: UILabel = {
        let view = UILabel()
        view.text = "Итого:"
        view.textColor = .black
        return view
    }()
    
    private lazy var sPayButton: SBPButton = {
        let view = SBPButton()
        view.tapAction = {
            self.sPayButtonTapped()
        }
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Swift"
        setupUI()
    }
    
    init(values: ConfigValues) {
        self.values = values
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CartCell.reuseID) as? CartCell else {
            return UITableViewCell()
        }
        cell.config(with: "Наушники", cost: (Int(values.cost ?? "2000") ?? 1) / tableView.numberOfRows(inSection: 0))
        return cell
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(paymentView)
        
        paymentView.addSubview(totalCostNameLabel)
        paymentView.addSubview(totalCostLabel)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: paymentView.topAnchor)
        ])
        
        paymentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            paymentView.heightAnchor.constraint(equalToConstant: .paymentHeight),
            paymentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            paymentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            paymentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        if SPay.isReadyForSPay {
            paymentView.addSubview(sPayButton)
            sPayButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                sPayButton.leadingAnchor.constraint(equalTo: paymentView.leadingAnchor,
                                                    constant: .margin),
                sPayButton.trailingAnchor.constraint(equalTo: paymentView.trailingAnchor,
                                                     constant: -.margin),
                sPayButton.bottomAnchor.constraint(equalTo: paymentView.bottomAnchor,
                                                   constant: -.bottomMargin)
            ])
        }
        
        totalCostNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            totalCostNameLabel.leadingAnchor.constraint(equalTo: paymentView.leadingAnchor,
                                                        constant: .margin),
            totalCostNameLabel.topAnchor.constraint(equalTo: paymentView.topAnchor)
        ])
        
        totalCostLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            totalCostLabel.trailingAnchor.constraint(equalTo: paymentView.trailingAnchor,
                                                     constant: -.margin),
            totalCostLabel.topAnchor.constraint(equalTo: paymentView.topAnchor)
        ])
    }
    
    private func sPayButtonTapped() {
        switch values.mode {
        case .Auto:
            autoPay()
        case .Manual:
            switch values.configMethod {
            case .OrderId:
                getPaymentToken()
            case .Purchase:
                paymentTokenWithPerchase()
            }
        }
    }
    
    private func getPaymentToken() {
        let request = SPaymentTokenRequest(merchantLogin: values.merchantLogin,
                                           orderId: values.orderId!,
                                           redirectUri: "testapp://test")
        SPay.getPaymentToken(with: self, with: request) { response in
            if let error = response.error {
                // Обработка ошибки
                print("\(error.errorDescription) - описание ошибки")
            } else {
                // Обработка успешно полученных данных...
                guard let paymentToken = response.paymentToken else { return }
                self.pay(with: paymentToken)
            }
        }
    }
    
    private func paymentTokenWithPerchase() {
        let request = SPaymentTokenRequest(redirectUri: "testapp://test",
                                           merchantLogin: values.merchantLogin,
                                           amount: Int(values.cost!) ?? 0,
                                           currency: values.currency!,
                                           mobilePhone: nil,
                                           orderNumber: values.orderNumber!,
                                           recurrentExipiry: "20230821",
                                           recurrentFrequency: 2)
        SPay.getPaymentToken(with: self, with: request) { response in
            if let error = response.error {
                // Обработка ошибки
                print("\(error.errorDescription) - описание ошибки")
            } else {
                // Обработка успешно полученных данных...
                guard let paymentToken = response.paymentToken else { return }
                self.pay(with: paymentToken)
            }
        }
    }
    
    private func autoPay() {
        let request = SFullPaymentRequest(merchantLogin: values.merchantLogin,
                                          orderId: values.orderId!,
                                          redirectUri: "testapp://test")
        SPay.payWithOrderId(with: self, with: request) { state, info  in
            switch state {
            case .success:
                print("Успешный результат")
            case .waiting:
                print("Необходимо проверить статус оплаты")
            case .error:
                print("\(info) - описание ошибки")
            @unknown default:
                print("Неопределенная ошибка")
            }
        }
    }
    
    private func pay(with token: String) {
        let request = SPaymentRequest(orderId: values.orderId!,
                                      paymentToken: token)
        SPay.pay(with: request) { state, info  in
            switch state {
            case .success:
                print("Успешный результат")
            case .waiting:
                print("Необходимо проверить статус оплаты")
            case .error:
                print("\(info) - описание ошибки")
            @unknown default:
                print("Неопределенная ошибка")
            }
        }
    }
    
    private func completePayment() {
        SPay.completePayment(paymentState: .success) {
            // Действия после закрытия шторки
        }
    }
}

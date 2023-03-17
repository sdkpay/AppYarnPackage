//
//  CartVC.swift
//  SberPay
//
//  Created by Alexander Ipatov on 07.11.2022.
//

import UIKit
import SberPaySDK

private extension CGFloat {
    static let paymentHeight = 200.0
    static let margin = 20.0
    static let bottomMargin = 50.0
}

final class CartVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let totalCost: Int
    private let apiKey: String
    private let autoMode: Bool
    private let orderId: String
    private let network: NetworkState
    private let sslOn: Bool
    private let purchase: Bool
    
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
        view.text = "\(String(totalCost)) p"
        view.textColor = .black
        return view
    }()
    
    private lazy var totalCostNameLabel: UILabel = {
        let view = UILabel()
        view.text = "Итого:"
        view.textColor = .black
        return view
    }()
    
    private lazy var sberPayButton: SBPButton = {
        let view = SBPButton()
        view.tapAction = {
            self.sberPayButtonTapped()
        }
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Swift"
        setupUI()
    }
    
    init(totalCost: Int,
         apiKey: String,
         orderId: String,
         autoMode: Bool,
         purchase: Bool,
         network: NetworkState,
         sslOn: Bool) {
        self.totalCost = totalCost
        self.apiKey = apiKey
        self.orderId = orderId
        self.autoMode = autoMode
        self.network = network
        self.sslOn = sslOn
        self.purchase = purchase
        super.init(nibName: nil, bundle: nil)
        SBPay.debugConfig(network: network, ssl: sslOn)
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
        cell.config(with: "Наушники", cost: totalCost / tableView.numberOfRows(inSection: 0))
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
        
        if SBPay.isReadyForSberPay {
            paymentView.addSubview(sberPayButton)
            sberPayButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                sberPayButton.leadingAnchor.constraint(equalTo: paymentView.leadingAnchor,
                                                       constant: .margin),
                sberPayButton.trailingAnchor.constraint(equalTo: paymentView.trailingAnchor,
                                                        constant: -.margin),
                sberPayButton.bottomAnchor.constraint(equalTo: paymentView.bottomAnchor,
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

    private func sberPayButtonTapped() {
        if autoMode {
            autoPay()
        } else {
            if purchase {
                paymentTokenWithPerchase()
            } else {
                getPaymentToken()
            }
        }
    }
    
    private func getPaymentToken() {
        let request = SBPaymentTokenRequest(apiKey: apiKey,
                                            merchantLogin: "Test shop",
                                            orderId: orderId,
                                            redirectUri: "sberPayExampleapp://sberidauth")
        SBPay.getPaymentToken(with: self, with: request) { response in
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
        let request = SBPaymentTokenRequest(apiKey: apiKey,
                                            redirectUri: "sberPayExampleapp://sberidauth",
                                            merchantLogin: "Test shop",
                                            amount: totalCost,
                                            currency: "643",
                                            mobilePhone: nil,
                                            orderNumber: orderId,
                                            recurrentExipiry: "20230821",
                                            recurrentFrequency: 2)
        SBPay.getPaymentToken(with: self, with: request) { response in
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
        let request = SBFullPaymentRequest(apiKey: apiKey,
                                           merchantLogin: "Test shop",
                                           orderId: orderId,
                                           redirectUri: "sberPayExampleapp://sberidauth")
        SBPay.payWithOrderId(viewController: self, paymentRequest: request) { state, info  in
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
        let request = SBPaymentRequest(apiKey: apiKey,
                                       orderId: "213132",
                                       paymentToken: "")
        SBPay.pay(with: request) { state, info  in
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
        SBPay.completePayment(paymentState: .success) {
            // Действия после закрытия шторки
        }
    }
}

//
//  CartVC.swift
//  SberPay
//
//  Created by Alexander Ipatov on 07.11.2022.
//

import UIKit
import SPaySdk

private extension CGFloat {
    static let paymentHeight = 200.0
    static let margin = 20.0
    static let bottomMargin = 50.0
}

final class CartVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let totalCost: Int
    private let apiKey: String
    private let merchantLogin: String
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
    
    init(totalCost: Int,
         apiKey: String,
         orderId: String,
         merchantLogin: String,
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
        self.merchantLogin = merchantLogin
        super.init(nibName: nil, bundle: nil)
        SPay.debugConfig(network: network, ssl: sslOn)
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
        let request = SPaymentTokenRequest(merchantLogin: merchantLogin,
                                           orderId: orderId,
                                           redirectUri: "sberPayExampleapp://sberidauth")
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
        let request = SPaymentTokenRequest(redirectUri: "sberPayExampleapp://sberidauth",
                                           merchantLogin: merchantLogin,
                                           amount: totalCost,
                                           currency: "643",
                                           mobilePhone: nil,
                                           orderNumber: orderId,
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
        let request = SFullPaymentRequest(merchantLogin: merchantLogin,
                                          orderId: orderId,
                                          redirectUri: "sberPayExampleapp://sberidauth")
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
        let request = SPaymentRequest(orderId: "213132",
                                      paymentToken: "")
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

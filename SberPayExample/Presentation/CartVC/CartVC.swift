//
//  CartVC.swift
//  SberPay
//
//  Created by Alexander Ipatov on 07.11.2022.
//

import UIKit
import SPaySdkDEBUG

private extension CGFloat {
    static let paymentHeight = 150.0
    static let margin = 20.0
    static let bottomMargin = 50.0
}

struct CellModel {
    var cost: Int
    var title: String
    var image: UIImage
    var color: UIColor
}

final class CartVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let values: ConfigValues
    private var model: [CellModel] = [
        .init(cost: 820+1370,
              title: "Кабель зарядный Lightning connector",
              image: UIImage(named: "charger")!,
              color: UIColor(red: 253/255, green: 241/255, blue: 233/255, alpha: 1)),
        .init(cost: 750,
              title: "Амбушюры для Apple Airpods Pro",
              image: UIImage(named: "headphones")!,
              color: UIColor(red: 237/255, green: 247/255, blue: 251/255, alpha: 1)),
        .init(cost: 45681,
              title: "Телевизор Hisense 65E7HQ",
              image: UIImage(named: "tv")!,
              color: UIColor(red: 254/255, green: 236/255, blue: 237/255, alpha: 1))
    ]
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.separatorStyle = .none
        view.backgroundColor = .white
        view.register(CartCell.self, forCellReuseIdentifier: CartCell.reuseID)
        view.register(PaymentSCell.self, forCellReuseIdentifier: PaymentSCell.reuseID)
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
        view.textColor = UIColor(red: 251/255, green: 137/255, blue: 78/255, alpha: 1)
        view.font = .systemFont(ofSize: 17, weight: .semibold)
        return view
    }()
    
    private lazy var totalCostNameLabel: UILabel = {
        let view = UILabel()
        view.text = "Итого"
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
        navigationItem.title = "Корзина"
        setupUI()
    }
    
    init(values: ConfigValues) {
        self.values = values
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? model.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CartCell.reuseID) as? CartCell else {
                return UITableViewCell()
            }
            let model = model[indexPath.row]
            cell.config(with: model.title, cost: model.cost, icon: model.image, color: model.color)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PaymentSCell.reuseID) as? PaymentSCell else {
                return UITableViewCell()
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 0 ? 116 : 80
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Способ оплаты"
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if section == 1 {
            guard let view = view as? UITableViewHeaderFooterView else { return }
            view.textLabel?.textColor = .black
//            view.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        }
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
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
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
                                           orderId: values.orderId ?? "",
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
                                           amount: Int(values.cost ?? "") ?? 0,
                                           currency: values.currency ?? "",
                                           mobilePhone: nil,
                                           orderNumber: values.orderNumber ?? "",
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
                                          orderId: values.orderId ?? "",
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
        let request = SPaymentRequest(orderId: values.orderId ?? "",
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

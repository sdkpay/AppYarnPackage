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
        .init(cost: 820 + 1370,
              title: "Кабель зарядный Lightning connector",
              image: UIImage(named: "charger")!,
              color: UIColor(red: 253 / 255, green: 241 / 255, blue: 233 / 255, alpha: 1)),
        .init(cost: 750,
              title: "Амбушюры для Apple Airpods Pro",
              image: UIImage(named: "headphones")!,
              color: UIColor(red: 237 / 255, green: 247 / 255, blue: 251 / 255, alpha: 1)),
        .init(cost: 45680,
              title: "Телевизор Hisense 65E7HQ",
              image: UIImage(named: "tv")!,
              color: UIColor(red: 254 / 255, green: 236 / 255, blue: 237 / 255, alpha: 1))
    ]

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.separatorStyle = .none
        view.backgroundColor = .white
        view.register(cellClass: CartCell.self)
        view.register(cellClass: PaymentSCell.self)
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
        view.text = "\(values.cost) p"
        view.textColor = UIColor(red: 251 / 255, green: 137 / 255, blue: 78 / 255, alpha: 1)
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
        addDebugGesture()
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
            let cell: CartCell = tableView.dequeueResuableCell(forIndexPath: indexPath)
            let model = model[indexPath.row]
            cell.config(with: model.title, cost: model.cost, icon: model.image, color: model.color)
            return cell
        } else {
            let cell: PaymentSCell = tableView.dequeueResuableCell(forIndexPath: indexPath)
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
        }
    }
    
    private func addDebugGesture() {
        let tapGr = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGr)
    }
    
    @objc
    private func viewTapped() {
        let vc = UIAlertController(title: "Обнаружено нажатие", message: "", preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(vc, animated: true)
    }

    private func showResult(title: String, message: String) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(vc, animated: true)
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
        case .WithoutRefresh:
            payWithoutRefresh()
        case .PartPay:
            bnplPay()
        }
    }
    
    private var redirectUri: String {
        
        if values.environment == .SandboxRealBankApp
            || values.environment == .SandboxWithoutBankApp
            || values.network == .Prom {
            return "sdkopfyncfkq://spay"
        } else {
            return "testapp://test"
        }
    }
    
    private func autoPay() {
        
        let request = SBankInvoicePaymentRequest(merchantLogin: values.merchantLogin,
                                                 bankInvoiceId: values.orderId ?? "",
                                                 orderNumber: values.orderNumber ?? "none",
                                                 redirectUri: redirectUri,
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
    
    private func bnplPay() {
        
        let request = SBankInvoicePaymentRequest(merchantLogin: values.merchantLogin,
                                                 bankInvoiceId: values.orderId ?? "",
                                                 orderNumber: values.orderNumber ?? "none",
                                                 redirectUri: redirectUri,
                                                 apiKey: values.apiKey)
        
        SPay.payWithPartPay(with: self, paymentRequest: request) { state, info in
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
    
    private func payWithoutRefresh() {
        
        let request = SBankInvoicePaymentRequest(merchantLogin: values.merchantLogin,
                                                 bankInvoiceId: values.orderId ?? "",
                                                 orderNumber: values.orderNumber ?? "none",
                                                 redirectUri: redirectUri,
                                                 apiKey: values.apiKey)
        
        SPay.payWithoutRefresh(with: self, paymentRequest: request) { state, info in
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
}

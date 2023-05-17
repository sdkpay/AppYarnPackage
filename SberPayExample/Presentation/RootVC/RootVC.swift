//
//  RootVC.swift
//  SPay
//
//  Created by Alexander Ipatov on 08.11.2022.
//

import UIKit
import SPaySdkDEBUG
import CoreFoundation
import SafariServices

private extension CGFloat {
    static let buttonHeight = 40.0
    static let bottomMargin = 50.0
    static let sideMargin = 20.0
}

struct PerchaseConfig: Codable {
    let currency: String?
    let mobilePhone: String?
    let orderNumber: String?
    let orderId: String?
    let orderDescription: String?
    let language: String?
    let recurrentExipiry: String?
    let recurrentFrequency: Int
}

enum RequestMethod: String, CaseIterable, Codable {
    case OrderId, Purchase
}

enum PayMode: String, CaseIterable, Codable {
    case Manual, Auto
}

enum Config: Int, CaseIterable, Codable {
    case apiKey, merchantLogin, cost, configMethod, orderId, currency, orderNumber, lang, mode, network, ssl
    case bnpl
    var title: String {
        switch self {
        case .apiKey:
            return "ApiKey:"
        case .merchantLogin:
            return "MerchantLogin:"
        case .cost:
            return "Cost:"
        case .configMethod:
            return "Config request method:"
        case .orderId:
            return "OdredId:"
        case .lang:
            return "Lang:"
        case .mode:
            return "Pay mode:"
        case .network:
            return "Network mode:"
        case .ssl:
            return "SSL:"
        case .currency:
            return "Currency:"
        case .orderNumber:
            return "OrderNumber:"
        case .bnpl:
            return "Bnpl:"
        }
    }
    
    var items: [String]? {
        switch self {
        case .lang:
            return ["Swift", "Obj-C"]
        case .mode:
            return PayMode.allCases.map({ $0.rawValue })
        case .network:
            return [NetworkState.Mocker.rawValue]
        case .configMethod:
            return RequestMethod.allCases.map({ $0.rawValue })
        default:
            return nil
        }
    }
}
/// PSI
/// "AFhdqaX970inj42EoOVuw+kAAAAAAAAADH8u5FkDlopXBsahjOkZA1CcQwTaKaUMQB/H1JNtlz7fSTFdvOcWXXvpgvzCkJDHyRrfKuxYc8p4wP5kcZN+ua3bxgqRjGQLNxI2b9askeQvt63cZNivX3EDIJz6Ywlk0omNVxAlneT7Z1Do/OSkelsZa5zVwVZbYV0yQVSz"
///
/// merchantLogin: 781000122206-22061013

/// IFT:
/// APgWA9brxUPpgEz/Qj0dHR4AAAAAAAAADDR8ezdUy7tW0Vvns+yzeJ8FMyClHvqjIdqYmXxYJ3MXG+CaM15S/073vf1A3RoXNTrl1DPxKEkvPBetfoURU7DBI0bkqayEmRROmV6Yu7vlgTwnyJt+88884H7yezp8lEkQ4/dRVlQgYChKGC1Hyi25i9I1TMA+SgxudCUwWMLJ7t7BgQ8wMgCAsLY=
///
/// merchantLogin: test_sberpay
struct ConfigValues: Codable {
    var apiKey = "APgWA9brxUPpgEz/Qj0dHR4AAAAAAAAADDR8ezdUy7tW0Vvns+yzeJ8FMyClHvqjIdqYmXxYJ3MXG+CaM15S/073vf1A3RoXNTrl1DPxKEkvPBetfoURU7DBI0bkqayEmRROmV6Yu7vlgTwnyJt+88884H7yezp8lEkQ4/dRVlQgYChKGC1Hyi25i9I1TMA+SgxudCUwWMLJ7t7BgQ8wMgCAsLY=" // swiftlint:disable:this line_length
    var cost = "2000"
    var merchantLogin = "test_sberpay"
    var configMethod = RequestMethod.OrderId
    var orderId = "a8c8dc9136924b858f3d1de2c028abda"
    var orderNumber = "5f3f7d10-7005-7afe-b756-f73001c896b1"
    var lang = "Swift"
    var mode = PayMode.Auto
    var network = NetworkState.Prom
    var currency = "643"
    var ssl = true
    var bnpl = true
    
    func getValue(for type: Config) -> String {
        switch type {
        case .apiKey:
            return apiKey
        case .merchantLogin:
            return merchantLogin
        case .cost:
            return cost
        case .orderId:
            return orderId
        case .configMethod:
            return configMethod.rawValue
        case .lang:
            return lang
        case .mode:
            return mode.rawValue
        case .network:
            return network.rawValue
        case .ssl:
            return ssl.description
        case .currency:
            return currency
        case .orderNumber:
            return orderNumber
        case .bnpl:
            return bnpl.description
        }
    }
    
    mutating func setValue(value: String, for type: Config) {
        switch type {
        case .apiKey:
            apiKey = value
        case .merchantLogin:
            merchantLogin = value
        case .cost:
            cost = value
        case .orderId:
            orderId = value
        case .lang:
            lang = value
        case .mode:
            mode = PayMode(rawValue: value) ?? .Auto
        case .network:
            network = NetworkState(rawValue: value) ?? .Prom
        case .ssl:
            ssl = value.bool ?? true
        case .configMethod:
            configMethod = RequestMethod(rawValue: value) ?? .OrderId
        case .currency:
            currency = value
        case .orderNumber:
            orderNumber = value
        case .bnpl:
            bnpl = value.bool ?? true
        }
    }
}

final class RootVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var paymentMethod: RequestMethod = .Purchase

    private var cellConfig: [Config] {
        switch paymentMethod {
        case .OrderId:
            return [
                .apiKey,
                .merchantLogin,
                .lang,
                .network,
                .mode,
                .configMethod,
                .orderId,
                .bnpl,
                .ssl
            ]
        case .Purchase:
            return [
                .apiKey,
                .merchantLogin,
                .lang,
                .network,
                .mode,
                .configMethod,
                .orderId,
                .orderNumber,
                .cost,
                .currency,
                .bnpl,
                .ssl
            ]
        }
    }
    
    private var values = ConfigValues()
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.separatorStyle = .none
        view.register(RootCell.self, forCellReuseIdentifier: RootCell.reuseID)
        view.register(SegmentedControlCell.self, forCellReuseIdentifier: SegmentedControlCell.reuseID)
        view.register(ButtonTypeCell.self, forCellReuseIdentifier: ButtonTypeCell.reuseID)
        view.register(SwitchCell.self, forCellReuseIdentifier: SwitchCell.reuseID)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.blue, for: .normal)
        button.setTitle("Config", for: .normal)
        button.addTarget(self, action: #selector(showCart), for: .touchUpInside)
        return button
    }()
    
    private lazy var removeUserDefaultsButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.blue, for: .normal)
        button.setTitle("Сlear User Defaults", for: .normal)
        button.addTarget(self, action: #selector(removeUserDefaultsData), for: .touchUpInside)
        return button
    }()
    
    private lazy var loader: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        view.backgroundColor = .gray
        view.layer.cornerRadius = 10
        view.center = view.center
        return view
    }()
    
    private lazy var removeLogsButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.blue, for: .normal)
        button.setTitle("Сlear logs", for: .normal)
        button.addTarget(self, action: #selector(removeLogs), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNav()
        prepareData()
        setupUI()
        setupTitle()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } 
    }
    
    private func setupTitle() {
        let ver = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "No info"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "No info"
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = attributes
        title = "🔨 \(ver)(\(build)) - \(values.getValue(for: .network))"
    }

    private func prepareData() {
        values = getConfig()
        paymentMethod = values.configMethod
        tableView.reloadData()
    }
    
    private func configNav() {
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh,
                                            target: self,
                                            action: #selector(cleareConfig))
        navigationItem.rightBarButtonItem = refreshButton
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch cellConfig[indexPath.row] {
        case .apiKey:
            return configStringCell(for: indexPath)
        case .merchantLogin:
            return configStringCell(for: indexPath)
        case .cost:
            return configStringCell(for: indexPath)
        case .configMethod:
            return configSermentCell(for: indexPath)
        case .orderId:
            return configStringCell(for: indexPath)
        case .currency:
            return configStringCell(for: indexPath)
        case .orderNumber:
            return configStringCell(for: indexPath)
        case .lang:
            return configSermentCell(for: indexPath)
        case .mode:
            return configSermentCell(for: indexPath)
        case .network:
            return configButtonCell(for: indexPath)
        case .ssl:
            return configSwitchCell(for: indexPath)
        case .bnpl:
            return configSwitchCell(for: indexPath)
        }
    }
    
    func configButtonCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTypeCell.reuseID) as? ButtonTypeCell else { return UITableViewCell() }
        let data = cellConfig[indexPath.row]
        cell.config(title: data.title, itemTitle: values.getValue(for: data)) {
            self.showNetworkTypeAlert()
        }
        return cell
    }
    
    func configStringCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RootCell.reuseID) as? RootCell else {
            return UITableViewCell()
        }
        let data = cellConfig[indexPath.row]
        cell.config(with: data.title, value: values.getValue(for: data), isButtonShowed: data == .orderId) { [weak self] value in
            self?.values.setValue(value: value, for: data)
        } buttonDidTap: {
            self.generateOrderID()
        }
        
        return cell
    }
    
    func configSwitchCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCell.reuseID) as? SwitchCell else {
            return UITableViewCell()
        }
        let data = cellConfig[indexPath.row]
        cell.config(with: data.title,
                    value: values.getValue(for: data)) { [weak self] value in
            self?.values.setValue(value: value, for: data)
        }
        return cell
    }
    
    func configSermentCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SegmentedControlCell.reuseID) as? SegmentedControlCell else {
            return UITableViewCell()
        }
        let data = cellConfig[indexPath.row]
        cell.config(title: data.title,
                    items: data.items ?? [],
                    selected: values.getValue(for: data)) { [weak self] value in
            guard let self = self else { return }
            self.values.setValue(value: value, for: data)
            if data == .configMethod {
                self.paymentMethod = RequestMethod(rawValue: value) ?? .OrderId
                if self.paymentMethod == .Purchase {
                    self.values.setValue(value: PayMode.Manual.rawValue, for: .mode)
                }
                self.tableView.reloadData()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellConfig.count
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(nextButton)
        view.addSubview(removeUserDefaultsButton)
        view.addSubview(removeLogsButton)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: removeUserDefaultsButton.topAnchor,
                                              constant: -.bottomMargin)
        ])
        
        removeUserDefaultsButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            removeUserDefaultsButton.topAnchor.constraint(equalTo: nextButton.topAnchor,
                                                          constant: -.bottomMargin),
            removeUserDefaultsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            removeUserDefaultsButton.heightAnchor.constraint(equalToConstant: .buttonHeight)
        ])
        
        removeLogsButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            removeLogsButton.topAnchor.constraint(equalTo: removeUserDefaultsButton.topAnchor,
                                                  constant: -.bottomMargin),
            removeLogsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            removeLogsButton.heightAnchor.constraint(equalToConstant: .buttonHeight)
        ])
        
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                               constant: -.bottomMargin),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.heightAnchor.constraint(equalToConstant: .buttonHeight)
        ])
    }
    
    @objc
    private func removeUserDefaultsData() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
        showAlert(text: "User defaults cleared")
    }
    
    @objc
    private func removeLogs() {
        let fm = FileManager.default
        let paths = fm.urls(for: .documentDirectory,
                            in: .userDomainMask)
        let logs = paths.compactMap { $0.appendingPathComponent("SBPayLogs") }
        
        do {
            try removeItems(urls: logs, fm: fm)
            showAlert(text: "Logs deleted")
        } catch {
            showAlert(text: error.localizedDescription)
        }
    }
    
    private func removeItems(urls: [URL], fm: FileManager) throws {
        try urls.forEach {
            do {
                try fm.removeItem(at: $0)
            } catch {
                throw error
            }
        }
    }
    
    @objc
    private func cleareConfig() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "ConfigValues")
        values = getConfig()
        tableView.reloadData()
    }

    @objc
    private func showCart() {
        addLoader()
        loader.startAnimating()
        let vc: UIViewController
        
        if values.lang == "Obj-C" {
            vc = ObjcCartVC()
        } else {
            vc = CartVC(values: values)
        }
        saveConfig()

        SPayDebug.debugConfig(network: values.network, ssl: values.ssl)
        SPay.setup(apiKey: values.apiKey, bnplPlan: values.bnpl) {
            self.loader.stopAnimating()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func saveConfig() {
        let defaults = UserDefaults.standard
        guard let encoded = try? JSONEncoder().encode(values) else { return }
        defaults.set(encoded, forKey: "ConfigValues")
    }
    
    private func getConfig() -> ConfigValues {
        let defaults = UserDefaults.standard
        if let data = defaults.value(forKey: "ConfigValues") as? Data,
           let decoded = try? JSONDecoder().decode(ConfigValues.self, from: data) {
            return decoded
        } else {
            return ConfigValues()
        }
    }
    
    private func showAlert(with title: String? = nil, text: String? = nil) {
        let alert = UIAlertController(title: title,
                                      message: text,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showNetworkTypeAlert() {
        let alert = UIAlertController(title: Config.network.title,
                                      message: nil,
                                      preferredStyle: .actionSheet)
        NetworkState.allCases.forEach {
            let action = UIAlertAction(title: $0.rawValue, style: .default) {
                self.values.setValue(value: $0.title ?? "", for: .network)
                self.setupTitle()
                self.tableView.reloadData()
            }
            alert.addAction(action)
        }
        present(alert, animated: true)
    }
    
    private func addLoader() {
        loader.center = view.center
        self.view.addSubview(loader)
        self.view.bringSubviewToFront(loader)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        loader.startAnimating()
    }
    
    private func generateOrderID() {
        addLoader()
        RequestHeandler()
            .response(schemaType: .sberbankIFT) { [weak self] model in
                guard let sbolBankInvoiceID = model?.externalParams.sbolBankInvoiceId,
                      let self else {
                    self?.loader.stopAnimating()
                    return
                }
                self.values.setValue(value: sbolBankInvoiceID, for: .orderId)
                self.tableView.reloadData()
                self.loader.stopAnimating()
            }
    }
}

extension String {
    var bool: Bool? {
        switch self.lowercased() {
        case "true", "t", "yes", "y":
            return true
        case "false", "f", "no", "n", "":
            return false
        default:
            if let int = Int(self) {
                return int != 0
            }
            return nil
        }
    }
}

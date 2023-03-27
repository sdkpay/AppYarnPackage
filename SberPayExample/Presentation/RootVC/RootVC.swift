//
//  RootVC.swift
//  SPay
//
//  Created by Alexander Ipatov on 08.11.2022.
//

import UIKit
import SPaySdk

private extension CGFloat {
    static let buttonHeight = 40.0
    static let bottomMargin = 50.0
    static let sideMargin = 20.0
}

enum Config: Int, CaseIterable, Codable {
    case apiKey, cost, orderId, configMethod, lang, mode, network, ssl
    
    var title: String {
        switch self {
        case .apiKey:
            return "ApiKey:"
        case .cost:
            return "Cost:"
        case .orderId:
            return "OdredId:"
        case .configMethod:
            return "Config request method:"
        case .lang:
            return "Lang:"
        case .mode:
            return "Pay mode:"
        case .network:
            return "Network mode:"
        case .ssl:
            return "SSL:"
        }
    }
    
    var items: [String]? {
        switch self {
        case .lang:
            return ["Swift", "Obj-C"]
        case .mode:
            return ["Manual", "Auto"]
        case .network:
            return NetworkState.allCases.map({ $0.rawValue })
        case .ssl:
            return ["On", "Off"]
        case .configMethod:
            return ["OrderId", "Purchase"]
        default:
            return nil
        }
    }
}

struct ConfigValues: Codable {
    var apiKey = "AFhdqaX970inj42EoOVuw+kAAAAAAAAADH8u5FkDlopXBsahjOkZA1CcQwTaKaUMQB/H1JNtlz7fSTFdvOcWXXvpgvzCkJDHyRrfKuxYc8p4wP5kcZN+ua3bxgqRjGQLNxI2b9askeQvt63cZNivX3EDIJz6Ywlk0omNVxAlneT7Z1Do/OSkelsZa5zVwVZbYV0yQVSz" // swiftlint:disable:this line_length
    var cost = "2000"
    var configMethod = "orderId"
    var orderId = "d9f4ccf2-6f68-4e46-916f-850058b670a3"
    var lang = "Swift"
    var mode = "Auto"
    var network = NetworkState.Prod
    var ssl = "On"
    
    func getValue(for type: Config) -> String {
        switch type {
        case .apiKey:
            return apiKey
        case .cost:
            return cost
        case .orderId:
            return orderId
        case .configMethod:
            return configMethod
        case .lang:
            return lang
        case .mode:
            return mode
        case .network:
            return network.rawValue
        case .ssl:
            return ssl
        }
    }
    
    mutating func setValue(value: String, for type: Config) {
        switch type {
        case .apiKey:
            apiKey = value
        case .cost:
            cost = value
        case .orderId:
            orderId = value
        case .lang:
            lang = value
        case .mode:
            mode = value
        case .network:
            network = NetworkState(rawValue: value) ?? .Prod
        case .ssl:
            ssl = value
        case .configMethod:
            configMethod = value
        }
    }
}

final class RootVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var cellConfig = Config.allCases
    private var values = ConfigValues()
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.separatorStyle = .none
        view.register(RootCell.self, forCellReuseIdentifier: RootCell.reuseID)
        view.register(SegmentedControlCell.self, forCellReuseIdentifier: SegmentedControlCell.reuseID)
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
        let ver = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "No info"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "No info"
        title = "🔨 \(ver)(\(build))"
    }
    
    private func prepareData() {
        values = getConfig()
    }
    
    private func configNav() {
        if #available(iOS 13.0, *) {
            let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh,
                                                target: self,
                                                action: #selector(cleareConfig))
            navigationItem.rightBarButtonItem = refreshButton
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if cellConfig[indexPath.row].items != nil {
            return configSwitchCell(for: indexPath)
        } else {
            return configStringCell(for: indexPath)
        }
    }
    
    func configStringCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RootCell.reuseID) as? RootCell else {
            return UITableViewCell()
        }
        let data = cellConfig[indexPath.row]
        cell.config(with: data.title,
                    value: values.getValue(for: data),
                    keyboardType: data == .cost ? .decimalPad : .default) { [weak self] value in
            self?.values.setValue(value: value, for: data)
        }
        return cell
    }
    
    func configSwitchCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SegmentedControlCell.reuseID) as? SegmentedControlCell else {
            return UITableViewCell()
        }
        let data = cellConfig[indexPath.row]
        cell.config(title: data.title,
                    items: data.items ?? [],
                    selected: values.getValue(for: data)) { [weak self] value in
            self?.values.setValue(value: value, for: data)
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
        let path = fm.urls(for: .documentDirectory,
                           in: .userDomainMask)[0]
            .appendingPathComponent("SBPayLogs")
        let log = path.appendingPathComponent("log.txt")
        do {
            try fm.removeItem(at: log)
            showAlert(text: "Logs deleted")
        } catch {
            showAlert(text: error.localizedDescription)
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
        let vc: UIViewController
        
        if values.lang == "Obj-C" {
            vc = ObjcCartVC()
        } else {
            vc = CartVC(totalCost: Int(values.cost) ?? 0,
                        apiKey: values.apiKey,
                        orderId: values.orderId,
                        autoMode: values.mode == "Auto",
                        purchase: values.configMethod == "Purchase",
                        network: values.network,
                        sslOn: values.ssl == "On")
        }
        saveConfig()
        navigationController?.pushViewController(vc, animated: true)
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
}

//
//  ConfigPresenter.swift
//  SPay
//
//  Created by Alexander Ipatov on 08.11.2022.
//

import UIKit
import SPaySdkDEBUG

enum SectionData: Int, CaseIterable {
    case config
    case order
    case script
    case next
}

enum CellType: String, CaseIterable {
    case apiKey, merchantLogin, cost, configMethod, orderId, currency, orderNumber, lang, mode, network, ssl, environment, bnpl, next
}

private struct ConfigCellTextModel {
    let name: String
    let placeholder: String?
    var value: String?
    var description: String?
    var maxLength: Int?
    var needButton: Int?
}

protocol ConfigPresenterProtocol {
    func cell(for indexPath: IndexPath) -> UITableViewCell
    func removeButtonTapped()
    func removeLogsTapped()
    func generateOrderIdTapped()
    func refreshData()
    func viewDidLoad()
    var sectionCount: Int { get }
    func numberRowInSection(section: Int) -> Int
}

final class ConfigPresenter: ConfigPresenterProtocol {
    private var sectionData = SectionData.allCases
    private var configValues = ConfigValues()
    
    private lazy var configMethod = configValues.configMethod
    
    weak var view: (ConfigVCProtocol & UIViewController)?
    
    var sectionCount: Int {
        sectionData.count
    }
    
    func numberRowInSection(section: Int) -> Int {
        guard let section = SectionData(rawValue: section) else { return 0 }
        return cellForSection(section).count
    }
    
    private func cellForSection(_ section: SectionData) -> [CellType] {
        switch section {
        case .config:
            return [
                .apiKey,
                .bnpl,
                .environment
            ]
        case .order:
            switch configMethod {
            case .OrderId:
                return [
                    .mode,
                    .configMethod,
                    .merchantLogin,
                    .orderId,
                    .orderNumber
                ]
            case .Purchase:
                return [
                    .mode,
                    .configMethod,
                    .merchantLogin,
                    .orderId,
                    .orderNumber,
                    .cost,
                    .currency
                ]
            }
        case .script:
            return [
                .network,
                .ssl,
                .lang
            ]
        case .next:
            return [
                .next
            ]
        }
    }
    
    func cell(for indexPath: IndexPath) -> UITableViewCell {
        let section = sectionData[indexPath.section]
        let type = cellForSection(section)[indexPath.row]
        switch type {
        case .apiKey:
            return apiKeyCell(type: type)
        case .merchantLogin:
            return merchantLoginCell(type: type)
        case .cost:
            return costCell(type: type)
        case .configMethod:
            return configMethodCell(type: type)
        case .orderId:
            return orderIdCell(type: type)
        case .currency:
            return currencyCell(type: type)
        case .orderNumber:
            return orderNumberCell(type: type)
        case .lang:
            return langCell(type: type)
        case .mode:
            return modeCell(type: type)
        case .network:
            return networkCell(type: type)
        case .ssl:
            return sslCell(type: type)
        case .environment:
            return environmentCell(type: type)
        case .bnpl:
            return bnplCell(type: type)
        case .next:
            return nextButtonCell(type: type)
        }
    }
    
    private func setupTitle() {
        let ver = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "No info"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "No info"
        view?.setTitle(title: "🔨 \(ver)(\(build)) - \(configValues.network.rawValue)")
    }
    
    func viewDidLoad() {
        setupTitle()
        view?.reload()
    }
    
    func removeLogsTapped() {
        let fm = FileManager.default
        let paths = fm.urls(for: .documentDirectory,
                            in: .userDomainMask)
        let logs = paths.compactMap { $0.appendingPathComponent("SBPayLogs") }
        
        do {
            try removeItems(urls: logs, fm: fm)
            view?.showAlert(with: "Logs deleted")
        } catch {
            view?.showAlert(with: error.localizedDescription)
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
    
    func removeButtonTapped() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
        view?.showAlert(with: "User defaults cleared")
        
        view?.reload()
        setupTitle()
    }
    
    func refreshData() {
        let defaults = UserDefaults.standard
        CellType.allCases.forEach { type in
            defaults.removeObject(forKey: type.rawValue)
        }
        
        view?.reload()
        setupTitle()
    }
    
    private func updateSection(section: SectionData) {
        view?.reloadSection(section: section.rawValue)
    }
    
    private func goForward() {
        view?.startLoader()
        let vc: UIViewController
        
        switch configValues.lang {
        case .Swift:
            vc = CartVC(values: configValues)
        case .Obj:
            vc = ObjcCartVC()
        }
        let environment: SEnvironment
        switch configValues.environment {
        case .Prod:
            environment = .prod
        case .SandboxWithoutBankApp:
            environment = .sandboxWithoutBankApp
        case .SandboxRealBankApp:
            environment = .sandboxRealBankApp
        }
        SPay.debugConfig(network: configValues.network, ssl: configValues.ssl)
        SPay.setup(apiKey: configValues.apiKey ?? "",
                   bnplPlan: configValues.bnpl,
                   environment: environment) {
            self.view?.stopLoader()
            self.view?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func generateOrderIdTapped() {
        alertWithTextField(title: "Generate order id",
                           message: "Params:",
                           textFields:
                            [
                                (text: configValues.orderNumber, placeholder: "OrderNumber"),
                                (text: configValues.cost, placeholder: "Cost"),
                                (text: configValues.currency, placeholder: "Сurrency")
                            ]
        ) { results in
            if #available(iOS 13.0, *) {
                self.generateOrder(orderNumber: results[0],
                                   amount: results[1],
                                   currency: results[2])
            }
        }
    }
    
    @available(iOS 13.0, *)
    private func generateOrder(orderNumber: String,
                               amount: String,
                               currency: String) {
        view?.startLoader()
        Task {
            do {
                let orderModel = try await OrderService.registerToken(stand: NetworkType(from: configValues.network),
                                                                      orderNumber: "123",
                                                                      amount: 123,
                                                                      currency: 1232)
                DispatchQueue.main.async {
                    self.configValues.orderId = orderModel.externalParams.sbolBankInvoiceId
                    self.view?.reload()
                    self.view?.stopLoader()
                }
            } catch {
                DispatchQueue.main.async {
                    self.view?.showAlert(with: error.localizedDescription)
                    self.view?.stopLoader()
                }
            }
        }
    }

    private func alertWithTextField(title: String? = nil,
                                    message: String? = nil,
                                    textFields: [(text: String?, placeholder: String)],
                                    completion: @escaping (([String]) -> Void) = { _ in }) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        for field in textFields {
            alert.addTextField { newTextField in
                newTextField.placeholder = field.placeholder
                newTextField.text = field.text
            }
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completion([]) })
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
            if let textFields = alert.textFields {
                completion(textFields.compactMap({ $0.text }) )
            } else { completion([]) }
        })
        view?.navigationController?.present(alert, animated: true)
    }
}

extension ConfigPresenter {
    private func apiKeyCell(type: CellType) -> UITableViewCell {
        let cell = TextViewCell()
        cell.config(title: "ApiKey",
                    text: configValues.apiKey,
                    placeholder: "ApiKey",
                    textEdited: { text in
            self.configValues.apiKey = text
        })
        return cell
    }
    
    private func merchantLoginCell(type: CellType) -> UITableViewCell {
        let cell = TextViewCell()
        cell.config(title: "MerchantLogin",
                    text: configValues.merchantLogin,
                    textEdited: { text in
            self.configValues.merchantLogin = text
        })
        return cell
    }
    
    private func costCell(type: CellType) -> UITableViewCell {
        let cell = TextViewCell()
        cell.config(title: "Cost",
                    text: configValues.cost,
                    textEdited: { text in
            self.configValues.cost = text
        })
        return cell
    }
    
    private func orderIdCell(type: CellType) -> UITableViewCell {
        let cell = TextViewCell()
        cell.config(title: "OrderId",
                    text: configValues.orderId,
                    textEdited: { text in
            self.configValues.orderId = text
        })
        return cell
    }
    
    private func currencyCell(type: CellType) -> UITableViewCell {
        let cell = TextViewCell()
        cell.config(title: "Currency",
                    text: configValues.currency,
                    textEdited: { text in
            self.configValues.currency = text
        })
        return cell
    }
    
    private func orderNumberCell(type: CellType) -> UITableViewCell {
        let cell = TextViewCell()
        cell.config(title: "OrderNumber",
                    text: configValues.orderNumber,
                    textEdited: { text in
            self.configValues.orderNumber = text
        })
        return cell
    }
    
    private func configMethodCell(type: CellType) -> UITableViewCell {
        let cell = SegmentedControlCell()
        cell.config(title: "RequestMethod",
                    items: RequestMethod.allCases.map({ $0.rawValue }),
                    selected: configValues.configMethod.rawValue) { item in
            self.configValues.configMethod = RequestMethod(rawValue: item) ?? .OrderId
            self.configMethod = RequestMethod(rawValue: item) ?? .OrderId
            self.updateSection(section: .order)
        }
        return cell
    }
    
    private func langCell(type: CellType) -> UITableViewCell {
        let cell = SegmentedControlCell()
        cell.config(title: "Lang",
                    items: Lang.allCases.map({ $0.rawValue }),
                    selected: configValues.lang.rawValue) { item in
            self.configValues.lang = Lang(rawValue: item) ?? .Swift
        }
        return cell
    }

    private func modeCell(type: CellType) -> UITableViewCell {
        let cell = SegmentedControlCell()
        cell.config(title: "Pay mode",
                    items: PayMode.allCases.map({ $0.rawValue }),
                    selected: configValues.mode.rawValue) { item in
            self.configValues.mode = PayMode(rawValue: item) ?? .Auto
        }
        return cell
    }
    
    private func sslCell(type: CellType) -> UITableViewCell {
        let cell = SwitchCell()
        cell.config(with: "SSL",
                    value: configValues.ssl) { bool in
            self.configValues.ssl = bool
        }
        
        return cell
    }
    
    private func bnplCell(type: CellType) -> UITableViewCell {
        let cell = SwitchCell()
        cell.config(with: "BNPL",
                    value: configValues.bnpl) { bool in
            self.configValues.bnpl = bool
        }
        return cell
    }
    
    private func networkCell(type: CellType) -> UITableViewCell {
        let cell = ListCell()
        cell.config(title: "Network mode",
                    value: configValues.network.rawValue) {
            self.view?.showSelectableAlert(with: "Network mode",
                                           items: NetworkState.allCases.map({ $0.rawValue }),
                                           selectedItem: { item in
                self.configValues.network = NetworkState(rawValue: item) ?? .Ift
                self.view?.reload()
                self.setupTitle()
            })
        }
        return cell
    }

    private func environmentCell(type: CellType) -> UITableViewCell {
        let cell = ListCell()
        cell.config(title: "Environment",
                    value: configValues.environment.rawValue) {
            self.view?.showSelectableAlert(with: "Environment",
                                           items: Environment.allCases.map({ $0.rawValue }),
                                           selectedItem: { item in
                self.configValues.environment = Environment(rawValue: item) ?? .Prod
                self.view?.reload()
                self.setupTitle()
            })
        }
        return cell
    }
    
    private func nextButtonCell(type: CellType) -> UITableViewCell {
        let cell = ButtonCell()
        cell.config(title: "Далее") {
            self.goForward()
        }
        return cell
    }
}

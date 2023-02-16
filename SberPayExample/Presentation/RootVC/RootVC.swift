//
//  RootVC.swift
//  SberPay
//
//  Created by Alexander Ipatov on 08.11.2022.
//

import UIKit
import SberPaySDK

private extension CGFloat {
    static let buttonHeight = 40.0
    static let bottomMargin = 50.0
    static let sideMargin = 20.0
}

final class RootVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private enum Params: Int, CaseIterable {
        case apiKey, cost, lang, mode
    }
    
    private var cellsData = [(type: Params, title: String, value: Any)]()
    
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
        prepareData()
        setupUI()
    }
    
    private var key: String {
      "AFhdqaX970inj42EoOVuw+kAAAAAAAAADH8u5FkDlopXBsahjOkZA1CcQwTaKaUMQB/H1JNtlz7fSTFdvOcWXXvpgvzCkJDHyRrfKuxYc8p4wP5kcZN+ua3bxgqRjGQLNxI2b9askeQvt63cZNivX3EDIJz6Ywlk0omNVxAlneT7Z1Do/OSkelsZa5zVwVZbYV0yQVSz" // swiftlint:disable:this line_length
    }
    
    private func prepareData() {
        cellsData = [
            (.apiKey, "ApiKey:", key),
            (.cost, "Cost:", "2000"),
            (.lang, "Lang:", false),
            (.mode, "Pay mode:", false)
        ]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = cellsData[indexPath.row]
        if cellData.type == .lang || cellData.type == .mode {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SegmentedControlCell.reuseID) as? SegmentedControlCell else {
                return UITableViewCell()
            }
            var items: [String] = []
            if cellData.type == .lang {
                items = ["Swift", "Obj-C"]
            } else if cellData.type == .mode {
                items = ["Manual", "Auto"]
            }
            cell.config(title: cellData.title, items: items) { [weak self] value in
                self?.cellsData[indexPath.row].value = value
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RootCell.reuseID) as? RootCell else {
                return UITableViewCell()
            }
            let cellData = cellsData[indexPath.row]
            cell.config(with: cellData.title,
                        value: cellData.value as? String ?? "",
                        keyboardType: cellData.type == .cost ? .decimalPad : .default) { [weak self] value in
                self?.cellsData[indexPath.row].value = value
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellsData.count
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
    private func showCart() {
        guard let cost = Int(cellsData.first(where: { $0.type == .cost })?.value as? String ?? "0"),
              let apiKey = cellsData.first(where: { $0.type == .apiKey })?.value as? String,
              let objSelected = cellsData.first(where: { $0.type == .lang })?.value as? Bool,
              let autoMode = cellsData.first(where: { $0.type == .mode })?.value as? Bool else {
            return
        }
        let vc: UIViewController
        if objSelected {
            vc = ObjcCartVC()
        } else {
            vc = CartVC(totalCost: cost,
                        apiKey: apiKey,
                        autoMode: autoMode)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showAlert(with title: String? = nil, text: String? = nil) {
        let alert = UIAlertController(title: title,
                                      message: text,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
}

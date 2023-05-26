//
//  ConfigVC.swift
//  SberPay
//
//  Created by Alexander Ipatov on 07.11.2022.
//

import UIKit
import SBLayout

private extension CGFloat {
    static let cellHeight = 50.0
}

protocol ConfigVCProtocol: AnyObject {
    func stopLoader()
    func startLoader()
    func reload()
    func reloadRow(_ indexPath: IndexPath, animate: Bool)
    func showAlert(with message: String)
    func showSelectableAlert(with title: String, items: [String], selectedItem: @escaping (String) -> Void) 
    func setTitle(title: String)
}

final class ConfigVC: UIViewController, ConfigVCProtocol {
    private var presenter: ConfigPresenterProtocol
    
    private lazy var loader: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        view.backgroundColor = .gray
        view.layer.cornerRadius = 10
        view.center = view.center
        return view
    }()
    
    private lazy var tableView: UITableView = {
        var tableView: UITableView
        if #available(iOS 13.0, *) {
            tableView = UITableView(frame: .zero, style: .insetGrouped)
        } else {
            tableView = UITableView(frame: .zero, style: .grouped)
        }
        tableView.register(TextViewCell.self, forCellReuseIdentifier: TextViewCell.reuseID)
        tableView.register(SegmentedControlCell.self, forCellReuseIdentifier: SegmentedControlCell.reuseID)
        tableView.register(SwitchCell.self, forCellReuseIdentifier: SwitchCell.reuseID)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.keyboardDismissMode = .interactive
        return tableView
    }()
    
    init(presenter: ConfigPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        setupUI()
        if #available(iOS 14.0, *) {
            addMenu()
        }
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loader.stopAnimating()
    }
    
    private func setupUI() {
        tableView
            .add(toSuperview: view)
            .touchEdge(SBEdge.top, toSuperviewEdge: .top)
            .touchEdge(SBEdge.left, toSuperviewEdge: SBEdge.left)
            .touchEdge(SBEdge.right, toSuperviewEdge: SBEdge.right)
            .touchEdge(SBEdge.bottom, toSuperviewEdge: SBEdge.bottom)
    }
    
    func startLoader() {
        loader.center = view.center
        view.addSubview(loader)
        view.bringSubviewToFront(loader)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        loader.startAnimating()
    }
    
    func stopLoader() {
        loader.stopAnimating()
    }
    
    func reload() {
        tableView.reloadData()
    }
    
    func reloadRow(_ indexPath: IndexPath, animate: Bool) {
        tableView.reloadRows(at: [indexPath], with: animate ? .fade : .none)
    }
    
    func setTitle(title: String) {
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = attributes
        self.title = title
    }
    
    @available(iOS 14.0, *)
    private func addMenu() {
        var menuItems: [UIAction] {
            return [
                UIAction(title: "Generate order",
                         image: UIImage(systemName: "network"),
                         handler: { _ in
                             self.presenter.generateOrderIdTapped()
                         }),
                UIAction(title: "Refresh data",
                         image: UIImage(systemName: "arrow.clockwise"),
                         handler: { _ in
                             self.presenter.refreshData()
                         }),
                UIAction(title: "Cleare logs",
                         image: UIImage(systemName: "trash"),
                         attributes: .destructive,
                         handler: { _ in
                             self.presenter.removeLogsTapped()
                         }),
                UIAction(title: "Cleare user data",
                         image: UIImage(systemName: "trash"),
                         attributes: .destructive,
                         handler: { _ in
                             self.presenter.removeButtonTapped()
                         })
            ]
        }
        let menu = UIMenu(title: "Settings",
                          image: nil,
                          identifier: nil,
                          options: [],
                          children: menuItems)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: nil,
                                                            image: UIImage(systemName: "gear"),
                                                            primaryAction: nil,
                                                            menu: menu)
    }
    
    func showAlert(with message: String) {
        let alertConteroller = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default)
        alertConteroller.addAction(alertAction)
        present(alertConteroller, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tableView.endEditing(true)
    }
    
    func showSelectableAlert(with title: String, items: [String], selectedItem: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title,
                                      message: nil,
                                      preferredStyle: .actionSheet)
        items.forEach { item in
            let action = UIAlertAction(title: item, style: .default) {_ in
                selectedItem(item)
            }
            alert.addAction(action)
        }
        present(alert, animated: true)
    }
}

extension ConfigVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        presenter.sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberRowInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        presenter.cell(for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        .cellHeight
    }
}

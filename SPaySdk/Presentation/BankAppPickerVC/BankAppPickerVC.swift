//
//  BankAppPickerVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 24.10.2023.
//

import UIKit

protocol IBankAppPickerVC: AnyObject {
    func reloadTableView()
    func setTilte(_ text: String)
}

final class BankAppPickerVC: ContentVC, IBankAppPickerVC {
    
    private let presenter: BankAppPickerPresenting
    private lazy var viewBuilder = BankAppPickerViewBuilder(backButtonDidTap: { [weak self] in
        self?.presenter.closeButtonDidTapped()
    })

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        viewBuilder.setupUI(view: view)
        viewBuilder.tableView.delegate = self
        viewBuilder.tableView.dataSource = self
        SBLogger.log(.didLoad(view: self))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SBLogger.log(.didAppear(view: self))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SBLogger.log(.didDissapear(view: self))
    }
    
    deinit {
        SBLogger.log(.stop(obj: self))
    }
    
    init(_ presenter: BankAppPickerPresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadTableView() {
        UIView.transition(with: viewBuilder.tableView,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: { self.viewBuilder.tableView.reloadData() },
                          completion: nil)
    }
    
    func setTilte(_ text: String) {
        viewBuilder.subtitleLabel.text = text
    }
}

extension BankAppPickerVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.bankAppCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BankAppCell = tableView.dequeueResuableCell(forIndexPath: indexPath)
        cell.selectionStyle = .none
        let model = presenter.model(for: indexPath)
        cell.config(with: model)
        return cell
    }
}

extension BankAppPickerVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectRow(at: indexPath)
    }
}

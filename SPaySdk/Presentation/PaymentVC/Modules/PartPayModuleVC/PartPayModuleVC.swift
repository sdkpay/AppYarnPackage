//
//  PartPayModuleVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 01.03.2024.
//

import UIKit

protocol IPartPayModuleVC {
    func setFinalCost(_ value: String)
    func setTitle(_ value: String)
    func setCommissionCount(_ value: Int)
    func configCheckView(text: String,
                         checkSelected: Bool,
                         checkTapped: @escaping BoolAction,
                         textTapped: @escaping LinkAction)
}

final class PartPayModuleVC: ModuleVC, IPartPayModuleVC {

    private lazy var viewBuilder = PartPayModuleViewBuilder()
    
    private let presenter: PartPayModulePresenting
    
    init(_ presenter: PartPayModulePresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        viewBuilder.partsTableView.dataSource = self
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
    
    func setFinalCost(_ value: String) {
        viewBuilder.finalCostLabel.text = value
    }
    
    func setTitle(_ value: String) {
        viewBuilder.titleLabel.text = value
    }
    
    func setCommissionCount(_ value: Int) {
        viewBuilder.commissionLabel.config(with: value)
    }
    
    func configCheckView(text: String,
                         checkSelected: Bool,
                         checkTapped: @escaping BoolAction,
                         textTapped: @escaping LinkAction) {
        viewBuilder.agreementView.config(with: text,
                                         checkSelected: checkSelected,
                                         checkTapped: checkTapped,
                                         textTapped: textTapped)
        viewBuilder.setupUI(view: view, needCommissionLabel: presenter.needCommission)
    }
}

extension PartPayModuleVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.partsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PartCell = tableView.dequeueResuableCell(forIndexPath: indexPath)
        cell.selectionStyle = .none
        let model = presenter.model(for: indexPath)
        cell.config(with: model)
        return cell
    }
}

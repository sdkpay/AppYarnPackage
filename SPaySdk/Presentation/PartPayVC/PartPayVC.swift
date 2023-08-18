//
//  PartPayVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 14.04.2023.
//

import UIKit

protocol IPartPayVC {
    func setFinalCost(_ value: String)
    func setSubtitle(_ value: String)
    func setTitle(_ value: String)
    func setButtonEnabled(value: Bool)
    func configCheckView(text: String,
                         checkSelected: Bool,
                         checkTapped: @escaping BoolAction,
                         textTapped: @escaping LinkAction)
}

final class PartPayVC: ContentVC, IPartPayVC {

    private lazy var viewBuilder = PartPayViewBuilder(acceptButtonTapped: {
        self.presenter.acceptButtonTapped()
    },
                                                 backButtonTapped: { 
        self.presenter.backButtonTapped()
    })
    
    private let presenter: PartPayPresenter
    private var analyticsService: AnalyticsService
        
    init(_ presenter: PartPayPresenter, analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topBarIsHidden = true
        presenter.viewDidLoad()
        viewBuilder.partsTableView.dataSource = self
        SBLogger.log(.didLoad(view: self))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.sendEvent(.BNPLViewAppeared)
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
    
    func setSubtitle(_ value: String) {
        viewBuilder.subTitleLabel.setAttributedString(lineHeightMultiple: 1.1, kern: -0.3, string: value)
    }
    
    func setButtonEnabled(value: Bool) {
        viewBuilder.acceptButton.isEnabled = value
    }
    
    func configCheckView(text: String,
                         checkSelected: Bool,
                         checkTapped: @escaping BoolAction,
                         textTapped: @escaping LinkAction) {
        viewBuilder.agreementView.config(with: text,
                                         checkSelected: checkSelected,
                                         checkTapped: checkTapped,
                                         textTapped: textTapped)
        viewBuilder.setupUI(view: view)
    }
}

extension PartPayVC: UITableViewDataSource {
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

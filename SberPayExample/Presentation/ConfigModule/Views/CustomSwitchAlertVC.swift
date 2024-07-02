//
//  CustomSwitchAlertVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 22.03.2024.
//

import UIKit

final class CustomSwitchAlertVC: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = .gray
        view.textAlignment = .center
        view.font = .systemFont(ofSize: 16, weight: .medium)
        view.sizeToFit()
        return view
    }()
    
    private var valuesDictionary = [(key: String, value: Bool)]()
    
    private lazy var backView: UIView = {
       
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        return view
    }()
    
    private lazy var okButton: ActionButton = {
        let view = ActionButton()
        view.setTitle("OK", for: .normal)
        view.setTitleColor(.link, for: .normal)
        view.addAction {
            self.dismiss(animated: true)
        }
        return view
    }()
    
    private var completion: ([String]) -> Void
    
    private lazy var contentStack: UIStackView = {
        
       let view = UIStackView()
        view.spacing = 4
        view.distribution = .fill
        view.axis = .vertical
        return view
    }()
    
    init(with title: String, values: [String], selected: [String], completion: @escaping ([String]) -> Void) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        self.titleLabel.text = title
        values.forEach({ valuesDictionary.append(($0, selected.contains($0))) })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configStack() {
        titleLabel.height(30)
        
        contentStack.addArrangedSubview(titleLabel)
        
        for (index, value) in valuesDictionary.enumerated() {
            
            let view = AlertSwitchPartView(value: value.key,
                                           state: value.value) { result in
                self.valuesDictionary[index].value = result
            }
            contentStack.addArrangedSubview(view)
        }
        
        okButton.height(30)
        
        contentStack.addArrangedSubview(okButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.isUserInteractionEnabled = true
        let tapGr = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGr)
        configStack()
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.completion(self.valuesDictionary
            .filter({ $0.value == true })
            .map({ $0.key }))
    }
    
    @objc
    private func viewTapped() {

        dismiss(animated: true)
    }
    
    private func setupUI() {
        
        view.backgroundColor = .black.withAlphaComponent(0.3)
        
        backView
            .add(toSuperview: view)
            .centerInSuperview(.y)
            .touchEdge(.left, toSameEdgeOfView: view, withInset: 40)
            .touchEdge(.right, toSameEdgeOfView: view, withInset: 40)
        
        contentStack
            .add(toSuperview: backView)
            .touchEdgesToSuperview([.left, .right])
            .touchEdge(.top, toEdge: .top, ofView: backView, withInset: 15)
            .touchEdge(.bottom, toEdge: .bottom, ofView: backView, withInset: 15)
    }
}

typealias BoolAction = ((Bool) -> Void)

private class AlertSwitchPartView: UIView {
    
    private var action: BoolAction
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = .gray
        view.font = .systemFont(ofSize: 13, weight: .medium)
        view.sizeToFit()
        return view
    }()
    
    private lazy var switchControl: UISwitch = {
        let view = UISwitch(frame: .zero)
        view.addTarget(self, action: #selector(switchControlChanged), for: .allEvents)
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fill
        view.alignment = .center
        view.axis = .horizontal
        view.spacing = 10
        view.addArrangedSubview(titleLabel)
        view.addArrangedSubview(switchControl)
        return view
    }()
    
    init(value: String, state: Bool, action: @escaping BoolAction) {
        self.action = action
        super.init(frame: .zero)
        titleLabel.text = value
        switchControl.isOn = state
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func switchControlChanged() {
        
       action(switchControl.isOn)
    }
     
    private func setupUI() {
        
        stackView
            .add(toSuperview: self)
            .touchEdgesToSuperview(withInsets: .init(top: 10,
                                                     left: 15,
                                                     bottom: 0,
                                                     right: 15))
    }
}

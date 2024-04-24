//
//  CustomTextAlertVC.swift
//  SPaySdkExample
//
//  Created by Ипатов Александр Станиславович on 24.04.2024.
//

import UIKit

final class CustomTextAlertVC: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = .gray
        view.textAlignment = .center
        view.font = .systemFont(ofSize: 16, weight: .medium)
        view.sizeToFit()
        return view
    }()
    
    private var values = [String]()
    
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
    
    private lazy var contentStack: UIStackView = {
        
       let view = UIStackView()
        view.spacing = 20
        view.distribution = .fill
        view.axis = .vertical
        return view
    }()
    
    init(with title: String, values: [String]) {
        super.init(nibName: nil, bundle: nil)
        self.titleLabel.text = title
        self.values = values
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configStack() {
        titleLabel.height(30)
        
        contentStack.addArrangedSubview(titleLabel)
        
        for value in values {
            
            let view = AlertTextPartView(value: value)
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

private class AlertTextPartView: UIView {

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = .black
        view.font = .systemFont(ofSize: 16, weight: .medium)
        view.isUserInteractionEnabled = true
        let tapGr = UITapGestureRecognizer(target: self, action: #selector(titleTapped))
        view.addGestureRecognizer(tapGr)
        view.sizeToFit()
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fill
        view.alignment = .center
        view.axis = .horizontal
        view.spacing = 15
        view.addArrangedSubview(titleLabel)
        return view
    }()
    
    init(value: String) {
        super.init(frame: .zero)
        titleLabel.text = value
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func titleTapped() {
        UIPasteboard.general.string = titleLabel.text
        titleLabel.text = "Скопировано"
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

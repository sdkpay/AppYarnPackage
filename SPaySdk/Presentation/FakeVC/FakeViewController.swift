//
//  FakeViewController.swift
//  SPaySdk
//
//  Created by Арсений on 31.03.2023.
//

import UIKit

final class FakeViewController: UIViewController {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.Fake.title
        label.font = .bodi3
        label.textColor = .black
        label.numberOfLines = 3
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupUI()
    }
    
    private func setupUI() {
        titleLabel
            .add(toSuperview: view)
            .centerInSuperview(.horizontal)
            .centerInSuperview(.vertical)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: 20)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: 20)
    }
}

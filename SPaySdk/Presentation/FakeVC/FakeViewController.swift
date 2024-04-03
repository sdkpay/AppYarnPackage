//
//  FakeViewController.swift
//  SPaySdk
//
//  Created by Арсений on 31.03.2023.
//

import UIKit

final class FakeViewController: UIViewController {
    
    private let completion: Action
    
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
        Task {
         await dismissWithDelay()
        }
    }
    
    init(completion: @escaping Action) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func dismissWithDelay() async {
        
        try? await Task.sleep(nanoseconds: UInt64(2) * 1000000000)
        
        completion()
        dismiss(animated: true)
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

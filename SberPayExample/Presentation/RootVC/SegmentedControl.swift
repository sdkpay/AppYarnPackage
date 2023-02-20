//
//  SegmentedControl.swift
//  SberPayExample
//
//  Created by Alexander Ipatov on 14.11.2022.
//

import UIKit

private extension CGFloat {
    static let topMargin = 15.0
    static let sideMargin = 20.0
}

final class SegmentedControlCell: UITableViewCell {
    static var reuseID: String { "SegmentedControl" }
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 2
        view.text = "Lang:"
        view.textColor = .black
        return view
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let view = UISegmentedControl()
        view.tintColor = .black
        view.selectedSegmentIndex = 0
        view.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fill
        view.axis = .vertical
        view.spacing = 10
        view.addArrangedSubview(titleLabel)
        view.addArrangedSubview(segmentedControl)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var selectedItem: ((Bool) -> Void)?
    
    func config(title: String, items: [String], selected: Int, selectedItem: @escaping (Bool) -> Void) {
        titleLabel.text = title
        self.selectedItem = selectedItem
        for (index, item) in items.enumerated() {
            segmentedControl.insertSegment(withTitle: item, at: index, animated: true)
        }
        segmentedControl.selectedSegmentIndex = selected
        setupUI()
    }
    
    @objc
    private func valueChanged() {
        selectedItem?(segmentedControl.selectedSegmentIndex == 1)
    }
    
    func setupUI() {
        backgroundColor = .white
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                           constant: .topMargin),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                               constant: .sideMargin),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                constant: -.sideMargin),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                              constant: -.topMargin)
        ])
    }
}

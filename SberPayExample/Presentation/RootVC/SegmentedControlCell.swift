//
//  SegmentedControlCell.swift
//  SPayExample
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
        view.backgroundColor = .darkGray
        view.selectedSegmentIndex = 0
        view.tintColor = .white
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
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var selectedItem: ((String) -> Void)?
    private var items: [String]?
    
    func config(title: String,
                items: [String],
                selected: String,
                selectedItem: @escaping (String) -> Void) {
        titleLabel.text = title
        self.selectedItem = selectedItem
        self.items = items
        segmentedControl.removeAllSegments()
        for (index, item) in items.enumerated() {
            segmentedControl.insertSegment(withTitle: item, at: index, animated: false)
        }
        segmentedControl.selectedSegmentIndex = items.firstIndex(of: selected) ?? 0
    }
    
    @objc
    private func valueChanged() {
        guard let items = items else { return }
        selectedItem?(items[segmentedControl.selectedSegmentIndex])
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

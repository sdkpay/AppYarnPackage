//
//  TextViewCell.swift
//  SberPay
//
//  Created by Alexander Ipatov on 07.11.2022.
//

import UIKit
import SBLayout

final class SegmentedControlCell: UITableViewCell {
    static var reuseID: String { "SegmentedControlCell" }

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = .gray
        view.font = .systemFont(ofSize: 13, weight: .medium)
        view.sizeToFit()
        return view
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let view = UISegmentedControl()
        view.addTarget(self, action: #selector(valueChanged),
                       for: .valueChanged)
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fill
        view.alignment = .center
        view.axis = .horizontal
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
        setupUI()
    }
    
    @objc
    private func valueChanged() {
        guard let items = items else { return }
        selectedItem?(items[segmentedControl.selectedSegmentIndex])
    }

    private func setupUI() {
        stackView
            .add(toSuperview: contentView)
            .touchEdge(SBEdge.top, toEdge: SBEdge.top, ofView: contentView)
            .touchEdge(SBEdge.left, toEdge: SBEdge.left, ofView: contentView, withInset: .sideMargin)
            .touchEdge(SBEdge.bottom, toEdge: SBEdge.bottom, ofView: contentView)
            .touchEdge(SBEdge.right, toEdge: SBEdge.right, ofView: contentView, withInset: .sideMargin)
    }
}

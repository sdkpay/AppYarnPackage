//
//  CardModuleVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 02.04.2024.
//

import UIKit

protocol ICardModuleVC {
    
    func addSnapShot()
    func reloadData()
}

final class CardModuleVC: ModuleVC, ICardModuleVC {
    
    private var presenter: CardModulePresenting
   
    private lazy var sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = {
        sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
        guard let sectionKind = CardSection(rawValue: sectionIndex) else { return nil }
        let section = CardSectionLayoutManager.getSectionLayout(layoutEnvironment: layoutEnvironment)
        return section
    }
    
    private(set) lazy var collectionView: CompactCollectionView = {
        let collectionView = CompactCollectionView(frame: .zero,
                                                   collectionViewLayout: PaymentCollectionViewLayoutManager.create(with: sectionProvider))
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(PaymentCardCell.self, forCellWithReuseIdentifier: PaymentCardCell.reuseId)
        return collectionView
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<CardSection, Int>?
    
    init(_ presenter: CardModulePresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configDataSource()
        presenter.viewDidLoad()
        collectionView.delegate = self
        setupUI()
    }
    
    func addSnapShot() {
        
        var snapshot = NSDiffableDataSourceSnapshot<CardSection, Int>()
        snapshot.appendSections(CardSection.allCases)
        print(snapshot.numberOfSections)
        CardSection.allCases.forEach { section in
            snapshot.appendItems(presenter.identifiresForSection(), toSection: section)
        }
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    func reloadData() {
        
        guard var newSnapshot = dataSource?.snapshot() else { return }
        newSnapshot.reloadSections(CardSection.allCases)
        dataSource?.apply(newSnapshot)
    }
    
    private func configDataSource() {
        
        dataSource = UICollectionViewDiffableDataSource<CardSection, Int>(collectionView: collectionView) { (
            collectionView: UICollectionView,
            indexPath: IndexPath,
            _: Int
        ) -> UICollectionViewCell? in
            guard let model = self.presenter.paymentModel(for: indexPath) else { return nil }
            return UICollectionView.config(collectionView: collectionView,
                                           cellType: PaymentCardCell.self,
                                           with: model,
                                           fot: indexPath)
        }
    }
    
    private func setupUI() {
        collectionView
            .add(toSuperview: view)
            .touchEdge(.left, toSuperviewEdge: .left, withInset: Cost.CollectionView.left)
            .touchEdge(.right, toSuperviewEdge: .right, withInset: Cost.CollectionView.right)
            .touchEdge(.bottom,
                       toEdge: .bottom,
                       ofView: view)
            .touchEdge(.top, toEdge: .top, ofView: view)
    }
}

extension CardModuleVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didSelectPaymentItem(at: indexPath)
    }
}

private extension CardModuleVC {
    enum Cost {
        static let sideOffSet: CGFloat = 32.0
        static let height = 56.0
        
        enum CollectionView {
            static let itemHeight: CGFloat = 72.0
            static let minimumLineSpacing: CGFloat = 8.0
            static let bottom: CGFloat = 20.0
            static let bottomToCancel: CGFloat = 8.0
            static let right: CGFloat = 16.0
            static let left: CGFloat = 16.0
            static let top: CGFloat = 8.0
        }
    }
}

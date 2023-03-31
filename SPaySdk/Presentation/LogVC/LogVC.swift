//
//  LogVC.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 30.03.2023.
//

import UIKit

protocol ILogVC {
    func setText(_ text: String)
    func scrollTo(_ range: NSRange)
    func setResultsNum(current: Int, count: Int)
    func hideResultsNum()
}

final class LogVC: UIViewController, ILogVC {
    private let presenter: LogPresenting

    private lazy var textView: UITextView = {
        let view = UITextView()
        view.isEditable = false
        view.textColor = .black
        return view
    }()
    
    private lazy var searchView: SearchInputView = {
       let view = SearchInputView()
        view.upAction = { [weak self] in
            self?.presenter.upTapped()
        }
        view.downAction = { [weak self] in
            self?.presenter.downTapped()
        }
        return view
    }()

    private lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchBar.delegate = self
        search.searchBar.searchBarStyle = .minimal
        search.searchBar.placeholder = "Нажмите для поиска по тексту"
        search.searchBar.inputAccessoryView = searchView
        return search
    }()
    
    init(_ presenter: LogPresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        setupNavVC()
        setupUI()
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
    
    private func setupNavVC() {
        title = "Logs"
        navigationController?.navigationBar.backgroundColor = .backgroundSecondary
        
        let settingsButton = UIBarButtonItem(barButtonSystemItem: .compose,
                                             target: self,
                                             action: #selector(settingTapped))
        navigationItem.leftBarButtonItem = settingsButton
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
    }
    
    @objc
    private func settingTapped() {
        self.presenter.downTapped()
    }
    
    func setText(_ text: String) {
        textView.text = text
    }
    
    func setResultsNum(current: Int, count: Int) {
        searchView.setResultsNum(current: current, count: count)
    }
    
    func hideResultsNum() {
        searchView.hideResultsNum()
    }
    
    func scrollTo(_ range: NSRange) {
        textView.selectedRange = range
        textView.scrollRangeToVisible(range)
        let rect = textView.layoutManager.boundingRect(forGlyphRange: range, in: textView.textContainer)
        let topTextInset = textView.textContainerInset.top
        let contentOffset = CGPoint(x: 0, y: topTextInset + rect.origin.y)

        textView.setContentOffset(contentOffset, animated: true)
        textView.highlight(range: range)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension LogVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        presenter.searchTextUpdated(text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter.searchTextUpdated("")
    }
}

extension UITextView {
    func highlight(range: NSRange) {
        let attributedOriginalText = NSMutableAttributedString(string: text)
        attributedOriginalText.addAttribute(NSAttributedString.Key.backgroundColor,
                                            value: UIColor.yellow,
                                            range: range)
        self.attributedText = attributedOriginalText
    }
}

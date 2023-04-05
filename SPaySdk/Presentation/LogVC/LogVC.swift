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

private extension TimeInterval {
    static let keyboardAnimateDuration = 0.5
}

private extension String {
    static let searchPlaceholder = "Нажмите для поиска по тексту"
}

final class LogVC: UIViewController, ILogVC {
    private let presenter: LogPresenting
    private var bottomAnchor: NSLayoutConstraint?

    private lazy var textView: UITextView = {
        let view = UITextView()
        view.textColor = .textPrimory
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
        search.searchBar.placeholder = .searchPlaceholder
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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.setContentOffset(.zero, animated: true)
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
        presenter.settingTapped()
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
        textView.scrollRangeToVisible(range)
        textView.highlight(range: range)
    }

    private func setupUI() {
        view.backgroundColor = .backgroundPrimary
        
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        bottomAnchor = textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomAnchor?.isActive = true
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc
    private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            bottomAnchor?.isActive = false
            bottomAnchor?.constant = -keyboardSize.height
            bottomAnchor?.isActive = true
            UIView.animate(withDuration: .keyboardAnimateDuration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc
    private func keyboardWillHide() {
        bottomAnchor?.constant = .zero
        bottomAnchor?.isActive = true
        UIView.animate(withDuration: .keyboardAnimateDuration) {
           self.view.layoutIfNeeded()
        }
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

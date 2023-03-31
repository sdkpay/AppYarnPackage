//
//  LogPresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 30.03.2023.
//

import UIKit

private extension String {
    static let noLogs = "Логи не найдены"
}

protocol LogPresenting {
    func viewDidLoad()
    func settingTapped()
    func upTapped()
    func downTapped()
    func searchTextUpdated(_ text: String)
}

final class LogPresenter: LogPresenting {
    private var logPath: URL? {
        let fm = FileManager.default
        return fm.urls(for: .documentDirectory,
                       in: .userDomainMask)[0]
            .appendingPathComponent("SBPayLogs")
            .appendingPathComponent("log.txt")
    }
    
    var logContent: String?
    
    private var searchRanges: [NSRange] = []
    private var currentRangeIndex = 0

    weak var view: (UIViewController & ILogVC)?
    
    func viewDidLoad() {
        getLogString()
        showAllText()
    }
    
    private func getLogString() {
        guard let logPath = logPath else { return }
        logContent = try? String(contentsOf: logPath)
    }
    
    private func showAllText() {
        let text = logContent ?? .noLogs
        view?.setText(text)
    }
    
    func settingTapped() {
        // TODO: добавить разбивку на группы
    }

    func upTapped() {
        guard currentRangeIndex - 1 >= 0 else { return }
        currentRangeIndex -= 1
        let range = searchRanges[currentRangeIndex]
        scrollToRange(range: range)
    }
    
    func downTapped() {
        guard currentRangeIndex + 1 <= searchRanges.count - 1 else { return }
        currentRangeIndex += 1
        let range = searchRanges[currentRangeIndex]
        scrollToRange(range: range)
    }
    
    func searchTextUpdated(_ text: String) {
        guard !text.isEmpty else {
            showAllText()
            view?.hideResultsNum()
            return
        }
        guard let logContent = logContent else { return }
        searchRanges = logContent.ranges(of: text, options: [.regularExpression, .caseInsensitive])
        currentRangeIndex = 0
        if let firstRange = searchRanges.first {
            scrollToRange(range: firstRange)
        } else {
            view?.setResultsNum(current: 0, count: searchRanges.count)
        }
    }
    
    private func scrollToRange(range: NSRange) {
        view?.scrollTo(range)
        view?.setResultsNum(current: currentRangeIndex + 1, count: searchRanges.count)
    }
}

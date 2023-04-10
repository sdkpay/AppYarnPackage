//
//  LogPresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 30.03.2023.
//

import UIKit

private extension String {
    static let noLogs = "Логи не найдены"
    static let title = "Логи"
}

protocol LogPresenting {
    func viewDidLoad()
    func settingTapped()
    func upTapped()
    func downTapped()
    func shareTapped()
    func searchTextUpdated(_ text: String)
}

final class LogPresenter: LogPresenting {
    private var logPath: URL? {
        let fm = FileManager.default
        return fm.urls(for: .documentDirectory,
                       in: .userDomainMask)[0]
            .appendingPathComponent("SBPayLogs")
            .appendingPathComponent("log_\(SBLogger.dateString).txt")
    }
    
    private var logContent: [String] = []
    private var filteredLogContent: [String] = []
    private var searchRanges: [NSRange] = []
    private var logLevel: DebugLogLevel?
    private var currentRangeIndex = 0

    weak var view: (UIViewController & ILogVC)?
    
    func viewDidLoad() {
        view?.title = .title
        getLogString()
        showAllText()
    }
    
    private func getLogString() {
        guard let logPath = logPath else { return }
        let logContentString = try? String(contentsOf: logPath)
        logContent = logContentString?.components(separatedBy: ["|"]) ?? []
    }
    
    private func showAllText() {
        let text = logContent.isEmpty ? .noLogs : logContent.joined(separator: "\n")
        view?.setText(text)
    }
    
    func settingTapped() {
        presentLogLevelPicker()
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
    
    func getLogPath() -> URL? {
        return logPath
    }
    
    func searchTextUpdated(_ text: String) {
        guard !text.isEmpty else {
            showAllText()
            view?.hideResultsNum()
            return
        }
        let content = logLevel == nil ? logContent : filteredLogContent
        searchRanges = content
            .joined(separator: "\n")
            .ranges(of: text, options: [.regularExpression, .caseInsensitive])
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

    private func presentLogLevelPicker() {
        let alertVC = LogLevelAlertVC { [weak self] level in
            self?.logLevel = level
            self?.view?.title = self?.logLevel?.rawValue ?? .title
            self?.filterLogs()
        }
        view?.present(alertVC, animated: true)
    }
    
    func shareTapped() {
        guard let path = getLogPath() else { return }
        let activityViewController = UIActivityViewController(activityItems: [path],
                                                              applicationActivities: nil)
        view?.present(activityViewController, animated: true)
    }
    
    private func filterLogs() {
        if let logLevel = logLevel {
            filteredLogContent = logContent.filter({ $0.hasPrefix(logLevel.rawValue) })
            view?.setText(filteredLogContent.joined(separator: "\n"))
        } else {
            view?.setText(logContent.joined(separator: "\n"))
        }
    }
}

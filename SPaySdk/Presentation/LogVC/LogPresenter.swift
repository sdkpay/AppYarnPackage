//
//  LogPresenter.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 30.03.2023.
//

import UIKit

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
    
    var logContent: String? {
        guard let logPath = logPath else { return nil }
        return try? String(contentsOf: logPath)
    }
    
    private var searchRanges: [NSRange] = []
    private var currentRangeIndex = 0

    weak var view: (UIViewController & ILogVC)?
    
    func viewDidLoad() {
        showAllText()
    }
    
    private func showAllText() {
        let text = logContent ?? "Логи не найдены"
        view?.setText(text)
    }
    
    func settingTapped() {
        // TODO: добавить разбивку на группы
    }

    func upTapped() {
        guard currentRangeIndex - 1 > 0 else { return }
        let index = currentRangeIndex - 1
        currentRangeIndex = index
        let range = searchRanges[index]
        view?.scrollTo(range)
        view?.setResultsNum(current: currentRangeIndex + 1, count: searchRanges.count)
    }
    
    func downTapped() {
        guard currentRangeIndex + 1 <= searchRanges.count else { return }
        let index = currentRangeIndex + 1
        currentRangeIndex = index
        let range = searchRanges[index]
        view?.scrollTo(range)
        view?.setResultsNum(current: currentRangeIndex + 1, count: searchRanges.count)
    }
    
    func searchTextUpdated(_ text: String) {
        guard !text.isEmpty else {
            showAllText()
            view?.hideResultsNum()
            return
        }
        guard let logContent = logContent else { return }
        searchRanges = logContent.ranges(of: text, options: [.regularExpression, .caseInsensitive])
        if let firstRange = searchRanges.first {
            view?.scrollTo(firstRange)
            view?.setResultsNum(current: currentRangeIndex + 1, count: searchRanges.count)
        } else {
            view?.setResultsNum(current: currentRangeIndex, count: searchRanges.count)
        }
    }
}

extension String {
    func ranges(of substring: String,
                options: CompareOptions = [],
                locale: Locale? = nil) -> [NSRange] {
            var ranges: [Range<Index>] = []
            while ranges.last.map({ $0.upperBound < self.endIndex }) ?? true,
                  let range = self.range(of: substring,
                                         options: options,
                                         range: (ranges.last?.upperBound ?? self.startIndex)..<self.endIndex,
                                         locale: locale) {
                ranges.append(range)
            }
        return ranges.map({ NSRange(range: $0, originalText: self) })
    }
}

extension NSRange {
    public init(range: Range<String.Index>,
                originalText: String) {
        self.init(location: range.lowerBound.utf16Offset(in: originalText),
                  length: range.upperBound.utf16Offset(in: originalText) - range.lowerBound.utf16Offset(in: originalText))
    }
}

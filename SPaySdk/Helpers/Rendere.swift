//
//  Rendere.swift
//  SPaySdk
//
//  Created by Арсений on 31.03.2023.
//

import Foundation

public protocol Renderer {
    func render(with stats: SessionMetrics)
}

public struct ConsoleRenderer: Renderer {
    public var printer: (String) -> Void = { SBLogger.log($0) }
    let columns = (left: 18, middle: 82, right: 8)

    public init() {

    }

    public func render(with stats: SessionMetrics) {
        var buffer: [String] = []
        buffer.append("Task ID: \(stats.task.taskIdentifier) lifetime: \(stats.taskInterval.duration.ms) redirects: \(stats.redirectCount)")
        for metric in stats.metrics {
            buffer.append(renderHeader(with: metric))
            buffer.append(renderMeta(with: metric))
            let total = totalDateInterval(from: metric)
            for line in metric.durations.filter({ $0.type != .total }) {
                buffer.append(renderDuration(line: line, total: total))
            }
            if let total = total {
                buffer.append(renderMetricSummary(for: total))
            }
        }

        printer(buffer.joined(separator: "\n"))
    }

    func totalDateInterval(from metric: Metric) -> DateInterval? {
        if let total = metric.durations.filter({ $0.type == .total }).first {
            return total.interval
        } else if let first = metric.durations.first  {
            // calculate total from all available Durations
            var total = first.interval
            total.duration += metric.durations.dropFirst().reduce(TimeInterval(0), { accumulated, duration in
                return accumulated + duration.interval.duration
            })
            return total
        }
        return nil
    }

    func renderHeader(with metric: Metric) -> String {
        let method = metric.transactionMetrics.request.httpMethod ?? "???"
        let url = metric.transactionMetrics.request.url?.absoluteString ?? "???"

        let responseLine: String
        if let response = metric.transactionMetrics.response as? HTTPURLResponse {
            let mime = response.mimeType ?? ""
            responseLine = "\(response.statusCode) \(mime)"
        } else {
            responseLine = "[response error]"
        }
        return "\(method) \(url) -> \(responseLine), through \(metric.transactionMetrics.resourceFetchType.name)"
    }

    func renderDuration(line: Metric.Duration, total: DateInterval?) -> String {
        let name = line.type.name.padding(toLength: columns.left, withPad: " ", startingAt: 0)
        let plot = total.flatMap({ visualize(interval: line.interval, total: $0, within: self.columns.middle) }) ?? ""
        let time = line.interval.duration.ms.leftPadding(toLength: columns.right, withPad: " ")
        return "\(name)\(plot)\(time)"
    }

    func visualize(interval: DateInterval, total: DateInterval, within: Int = 100) -> String {
        precondition(total.intersects(total), "supplied duration does not intersect with the total duration")
        let width = within - 2
        if interval.duration == 0 {
            return "|" + String(repeatElement(" ", count: width)) + "|"
        }

        let relativeStart = (interval.start.timeIntervalSince1970 - total.start.timeIntervalSince1970) / total.duration
        let relativeEnd = 1.0 - (total.end.timeIntervalSince1970 - interval.end.timeIntervalSince1970) / total.duration

        let factor = 1.0 / Double(width)
        let startIndex = Int((relativeStart / factor))
        let endIndex = Int((relativeEnd / factor))

        let line: [String] = (0..<width).map { position in
            if position >= startIndex && position <= endIndex {
                return "#"
            } else {
                return " "
            }
        }
        return "|\(line.joined())|"
    }

    func renderMeta(with metric: Metric) -> String {
        let networkProtocolName = metric.transactionMetrics.networkProtocolName ?? "???"
        let meta = [
            "protocol: \(networkProtocolName)",
            "proxy: \(metric.transactionMetrics.isProxyConnection)",
            "reusedconn: \(metric.transactionMetrics.isReusedConnection)",
        ]
        return meta.joined(separator: " ")
    }

    func renderMetricSummary(for interval: DateInterval) -> String {
        let width = columns.left + columns.middle + columns.right
        return "total   \(interval.duration.ms)".leftPadding(toLength: width, withPad: " ")
    }
}

private extension TimeInterval {
    var ms: String {
        return String(format: "%.1fms", self * 1000)
    }
}

private extension String {
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let newLength = count
        if newLength < toLength {
            return String(repeatElement(character, count: toLength - newLength)) + self
        } else {
            return self.substring(from: index(self.startIndex, offsetBy: newLength - toLength))
        }
    }
}

//
//  SessionMetrix.swift
//  SPaySdk
//
//  Created by Арсений on 31.03.2023.
//

import Foundation

public struct SessionMetrics {
    public let task: URLSessionTask
    public let metrics: [Metric]
    public let redirectCount: Int
    public let taskInterval: DateInterval

    public init(source sessionTaskMetrics: URLSessionTaskMetrics, task: URLSessionTask) {
        self.task = task
        self.redirectCount = sessionTaskMetrics.redirectCount
        self.taskInterval = sessionTaskMetrics.taskInterval
        self.metrics = sessionTaskMetrics.transactionMetrics.map(Metric.init(transactionMetrics:))
    }

    public func render(with renderer: Renderer) {
        renderer.render(with: self)
    }
}

public final class SessionMetricsLogger: NSObject, URLSessionTaskDelegate {
    let renderer = ConsoleRenderer()
    var enabled = true

    public func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        guard enabled else { return }

        let gatherer = SessionMetrics(source: metrics, task: task)
        renderer.render(with: gatherer)
    }
}

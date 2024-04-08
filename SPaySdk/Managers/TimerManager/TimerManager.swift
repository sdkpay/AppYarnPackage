//
//  TimerManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 03.12.2023.
//

import Foundation
import UIKit

typealias IntAction = ((Int) -> Void)

protocol TimerManager {
    func setup(sec: Int)
    func start()
    func update(completion: @escaping IntAction)
    func stop()
}

final class DefaultTimerManager: TimerManager {
    
    private var timer: Timer?
    private var updateAction: IntAction?
    
    private var maxSec: Int = 0
    private var currentSec: Int = 0
    private var appDidEnterBackgroundDate: Date?
    
    func setup(sec: Int) {
        self.maxSec = sec
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidEnterBackground(_:)),
                                               name: UIApplication.didEnterBackgroundNotification, 
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillEnterForeground(_:)),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func applicationDidEnterBackground(_ notification: NotificationCenter) {
        appDidEnterBackgroundDate = Date()
    }

    @objc func applicationWillEnterForeground(_ notification: NotificationCenter) {
        guard let previousDate = appDidEnterBackgroundDate else { return }
        let calendar = Calendar.current
        let difference = calendar.dateComponents([.second], from: previousDate, to: Date())
        let seconds = difference.second!
        currentSec -= seconds
    }
    
    func start() {
        
        currentSec = maxSec
        
        timer = Timer(timeInterval: 1.0,
                      target: self,
                      selector: #selector(updateTime),
                      userInfo: nil,
                      repeats: true)
        guard let timer else { return }
        RunLoop.current.add(timer, forMode: .common)
    }
    
    func update(completion: @escaping IntAction) {
        
        updateAction = completion
    }
    
    func stop() {
        
        timer?.invalidate()
        timer = nil
        removeNotifications()
    }
    
    @objc
    private func updateTime() {
        
        currentSec -= 1
        
        if currentSec < 0 {
            stop()
        } else {
            updateAction?(currentSec)
        }
    }
}

//
//  TimerManager.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 03.12.2023.
//

import Foundation

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
    
    func setup(sec: Int) {
        self.maxSec = sec
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

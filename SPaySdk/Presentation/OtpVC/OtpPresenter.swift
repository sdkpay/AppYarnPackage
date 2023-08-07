//
//  OtpPresenter.swift
//  SPaySdk
//
//  Created by Арсений on 02.08.2023.
//

import Foundation

protocol OtpPresenting {
    func viewDidLoad()
    func getNumber()
}

final class OtpPresenter: OtpPresenting {
    weak var view: IOtpVC?
    private var sec = 60
    private var timer: Timer? = nil

    
    func viewDidLoad() {
        createTimer()
    }
    
    func getNumber() {
        
    }
    
    func createTimer() {
        timer = Timer(timeInterval: 1.0,
                       target: self,
                       selector: #selector(updateTime),
                       userInfo: nil,
                       repeats: false)
        guard let timer else { return }
        RunLoop.current.add(timer, forMode: .common)
    }
    
    @objc private func updateTime() {
        sec -= 1
        if sec <= 0 {
            timer?.invalidate()
            sec = 60
            timer = nil
        } else {
            view?.updateTimer(sec: sec)
        }
    }
}

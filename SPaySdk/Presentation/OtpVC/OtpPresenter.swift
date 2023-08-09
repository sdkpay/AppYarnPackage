//
//  OtpPresenter.swift
//  SPaySdk
//
//  Created by Арсений on 02.08.2023.
//

import Foundation

protocol OtpPresenting {
    func viewDidLoad()
    func getOTP()
    func sendOTP(otpCode: String)
}

final class OtpPresenter: OtpPresenting {
    weak var view: IOtpVC?
    
    private var otpService: OTPService
    private var userService: UserService
    private let sdkManager: SDKManager
    private var sec = 45
    private var timer: Timer?

    init(otpService: OTPService, userService: UserService, sdkManager: SDKManager) {
        self.otpService = otpService
        self.userService = userService
        self.sdkManager = sdkManager
    }
    
    func viewDidLoad() {
        createTimer()
    }
    
    func getOTP() {
        otpService.creteOTP(orderId: userService.user?.sessionId ?? "",
                            sessionId: userService.user?.sessionId ?? "",
                            paymentId: Int(userService.selectedCard?.paymentId ?? 0)) { error, target, mobilePhone in
            guard let error else {
                // show error
                return
            }
            
            if target, let mobilePhone {
                self.view?.updateMobilePhone(phoneNumber: mobilePhone)
            }
        }
    }
    
    func sendOTP(otpCode: String) {
        let otpHash = getHashCode(code: otpCode)
        otpService.confirmOTP(orderId: sdkManager.authInfo?.orderId ?? "",
                              orderHash: otpHash,
                              sessionId: userService.user?.sessionId ?? "") { error, target in
            
        }
    }
    
    private func getHashCode(code: String) -> String {
        return code.hashValue.description + (userService.selectedCard?.cardNumber ?? "")
    }
    
    func createTimer() {
        timer = Timer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: false)
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

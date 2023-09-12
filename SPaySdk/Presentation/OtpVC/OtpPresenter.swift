//
//  OtpPresenter.swift
//  SPaySdk
//
//  Created by Арсений on 02.08.2023.
//

import UIKit

protocol OtpPresenting {
    func viewDidLoad()
    func getOTP()
    func sendOTP(otpCode: String)
    func back()
}

final class OtpPresenter: OtpPresenting {
    weak var view: (IOtpVC & ContentVC)?
    
    private var otpService: OTPService
    private var userService: UserService
    private let sdkManager: SDKManager
    private let alertService: AlertService
    private let authManager: AuthManager
    private let keyboardManager: KeyboardManager
    private var sec = 45
    private var countOfErrorPayment = 0
    private var timer: Timer?
    private var completion: Action?

    init(otpService: OTPService,
         userService: UserService,
         sdkManager: SDKManager,
         alertService: AlertService,
         keyboardManager: KeyboardManager,
         authManager: AuthManager,
         completion: @escaping Action) {
        self.otpService = otpService
        self.userService = userService
        self.sdkManager = sdkManager
        self.alertService = alertService
        self.completion = completion
        self.keyboardManager = keyboardManager
        self.authManager = authManager
        self.setKeyboardHeight()
    }
    
    func viewDidLoad() {
        createTimer()
        getOTP()
        configViews()
    }
    
    func setKeyboardHeight() {
        let height = keyboardManager.getKeyboardHeight()
        view?.setKeyboardHeight(height: height)
    }
    
    func getOTP() {
        view?.showLoading()
        otpService.creteOTP(orderId: sdkManager.authInfo?.orderId ?? "",
                            paymentId: Int(userService.selectedCard?.paymentId ?? 0)) { [weak self] result in
            switch result {
            case .success(let mobilePhone):
                guard let self else { return }
                let mobilePhone = mobilePhone ?? self.authManager.userInfo?.mobilePhone
                self.view?.updateMobilePhone(phoneNumber: mobilePhone ?? "none")
                self.view?.hideLoading()
            case .failure(let error):
                self?.alertService.show(on: self?.view, type: .defaultError(completion: { self?.dismissWithError(error) }))
                self?.view?.hideLoading()
            }
        }
    }
    
    private func configViews() {
        guard let user = userService.user else { return }
        view?.configProfileView(with: user.userInfo)
    }
    
    func sendOTP(otpCode: String) {
        let otpHash = getHashCode(code: otpCode)
        view?.showLoading()
        otpService.confirmOTP(orderId: sdkManager.authInfo?.orderId ?? "",
                              orderHash: otpHash) { result in
            switch result {
            case .success:
                self.view?.hideKeyboard()
                self.view?.hideLoading()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                    self?.closeWithSuccess()
                }
            case .failure(let error):
                if error.represents(.errorWithErrorCode(number: OtpError.incorrectCode.rawValue)) {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.view?.hideLoading(animate: true)
                        self.view?.showError()
                    }
                } else if error.represents(.errorWithErrorCode(number: OtpError.tryingError.rawValue)) {
                    self.alertService.show(on: self.view, type: .tryingError(back: {
                        self.view?.dismiss(animated: true)
                    }))
                } else {
                    self.alertService.show(on: self.view, type: .defaultError(completion: { self.dismissWithError(error) }))
                    self.view?.hideLoading()
                }
            }
        }
    }
        
    func back() {
        self.view?.hideKeyboard()
        view?.contentNavigationController?.popViewController(animated: true)
    }
    
    private func closeWithSuccess() {
        view?.contentNavigationController?.popViewController(animated: false, completion: {
            self.completion?()
        })
    }
    
    private func dismissWithError(_ error: SDKError) {
        alertService.close(animated: true, completion: { [weak self] in
            self?.sdkManager.completionWithError(error: error)
        })
    }
    
    private func getHashCode(code: String) -> String {
        return code.hashValue.description + (userService.selectedCard?.cardNumber ?? "")
    }
    
    func createTimer() {
        timer = Timer(timeInterval: 1.0,
                      target: self,
                      selector: #selector(updateTime),
                      userInfo: nil,
                      repeats: true)
        guard let timer else { return }
        RunLoop.current.add(timer, forMode: .common)
    }
    
    @objc private func updateTime() {
        sec -= 1
        if sec < 0 {
            timer?.invalidate()
            timer = nil
            sec = 45
        } else {
            view?.updateTimer(sec: sec)
        }
    }
}

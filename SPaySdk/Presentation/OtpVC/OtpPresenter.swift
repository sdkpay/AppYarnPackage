//
//  OtpPresenter.swift
//  SPaySdk
//
//  Created by Арсений on 02.08.2023.
//

import UIKit

protocol OtpPresenting {
    func viewDidLoad()
    func sendOTP(otpCode: String)
    func createOTP()
    func back()
    func viewDidAppear()
    func viewDidDisappear()
}

final class OtpPresenter: OtpPresenting {
    weak var view: (IOtpVC & ContentVC)?
    
    private var otpService: OTPService
    private var userService: UserService
    private let sdkManager: SDKManager
    private let alertService: AlertService
    private let authManager: AuthManager
    private let analitics: AnalyticsService
    private let keyboardManager: KeyboardManager
    private var sec = 45
    private var countOfErrorPayment = 0
    private var timer: Timer?
    private var completion: Action?
    private var otpRetryMaxCount = 3
    private var otpRetryCount = 1

    init(otpService: OTPService,
         userService: UserService,
         authManager: AuthManager,
         sdkManager: SDKManager,
         alertService: AlertService,
         analitics: AnalyticsService,
         keyboardManager: KeyboardManager,
         completion: @escaping Action) {
        self.otpService = otpService
        self.userService = userService
        self.authManager = authManager
        self.sdkManager = sdkManager
        self.alertService = alertService
        self.completion = completion
        self.analitics = analitics
        self.keyboardManager = keyboardManager
        self.setKeyboardHeight()
    }
    
    func viewDidLoad() {
        createTimer()
        configViews()
        userService.clearData()
    }
    
    func setKeyboardHeight() {
        let height = keyboardManager.getKeyboardHeight()
        view?.setKeyboardHeight(height: height)
    }
    
    private func configViews() {
        guard let user = userService.user else { return }
        view?.configProfileView(with: user.userInfo)
        view?.updateMobilePhone(phoneNumber: otpService.otpModel?.mobilePhone ?? "none")
    }
    
    func createOTP() {
        analitics.sendEvent(.RQCreteOTP)
        view?.showLoading()
        otpService.creteOTP { [weak self] result in
            switch result {
            case .success:
                self?.view?.hideLoading(animate: true)
                self?.updateTimerView()
                self?.createTimer()
                self?.analitics.sendEvent(.RQGoodCreteOTP)
            case .failure(let error):
                self?.analitics.sendEvent(.RSFailCreteOTP)
                self?.view?.hideLoading(animate: true)
                if error.represents(.noInternetConnection) {
                    self?.alertService.show(on: self?.view,
                                            type: .noInternet(retry: { self?.createOTP() },
                                                              completion: { self?.dismissWithError(error) }))
                } else {
                    self?.alertService.show(on: self?.view,
                                            type: .defaultError(completion: { self?.dismissWithError(error) }))
                }
            }
        }
    }
    
    func sendOTP(otpCode: String) {
        let otpHash = getHashCode(code: otpCode)
        view?.showLoading()
        analitics.sendEvent(.RQConfirmOTP)
        otpRetryCount += 1
        otpService.confirmOTP(otpHash: otpHash) { [weak self]  result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.analitics.sendEvent(.RSGoodConfirmOTP)
                self.view?.hideKeyboard()
                self.closeWithSuccess()
            case .failure(let error):
                self.analitics.sendEvent(.RSFailConfirmOTP)
                if error.represents(.errorWithErrorCode(number: OtpError.incorrectCode.rawValue)) {
                    if self.otpRetryCount > self.otpRetryMaxCount {
                        self.alertService.show(on: self.view, type: .tryingError(back: {
                            self.dismissWithError(.cancelled)
                        }))
                        return
                    }
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.view?.hideLoading(animate: true)
                        self.view?.showError(with: Strings.TextField.Error.Wrong.title)
                    }
                } else if error.represents(.errorWithErrorCode(number: OtpError.tryingError.rawValue)) {
                    self.alertService.show(on: self.view, type: .tryingError(back: {
                        self.dismissWithError(.cancelled)
                    }))
                } else if error.represents(.errorWithErrorCode(number: OtpError.timeOut.rawValue)) {
                    if self.otpRetryCount > self.otpRetryMaxCount {
                        self.alertService.show(on: self.view, type: .tryingError(back: {
                            self.dismissWithError(.cancelled)
                        }))
                        return
                    }
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.view?.hideLoading(animate: true)
                        self.view?.showError(with: Strings.TextField.Error.Timeout.title)
                    }
                } else {
                    self.alertService.show(on: self.view, type: .defaultError(completion: { self.dismissWithError(error) }))
                    self.view?.hideLoading()
                }
            }
        }
    }
        
    func back() {
        analitics.sendEvent(.TouchBack, with: [AnalyticsKey.view: AnlyticsScreenEvent.OtpVC.rawValue])
        view?.dismiss(animated: true, completion: { [weak self] in
            self?.sdkManager.completionWithError(error: .cancelled)
        })
    }
    
    func viewDidAppear() {
        analitics.sendEvent(.LCOTPViewAppeared)
    }
    
    func viewDidDisappear() {
        analitics.sendEvent(.LCOTPViewDisappeared)
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
        (code + (userService.selectedCard?.cardNumber ?? "")).sha256()
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
        if sec < 0 {
            timer?.invalidate()
            timer = nil
            sec = 45
        } else {
            updateTimerView()
        }
    }
    
    private func updateTimerView() {
        view?.updateTimer(sec: sec)
        sec -= 1
    }
}

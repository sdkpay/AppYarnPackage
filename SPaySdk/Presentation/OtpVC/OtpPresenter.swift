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
    private let analytics: AnalyticsService
    private let keyboardManager: KeyboardManager
    private let completionManager: CompletionManager
    private let parsingErrorAnaliticManager: ParsingErrorAnaliticManager
    private var sec = 45
    private var timer: Timer?
    private var completion: Action?
    
    init(otpService: OTPService,
         userService: UserService,
         authManager: AuthManager,
         sdkManager: SDKManager,
         alertService: AlertService,
         analytics: AnalyticsService,
         completionManager: CompletionManager,
         keyboardManager: KeyboardManager,
         parsingErrorAnaliticManager: ParsingErrorAnaliticManager,
         completion: @escaping Action) {
        self.otpService = otpService
        self.userService = userService
        self.authManager = authManager
        self.sdkManager = sdkManager
        self.alertService = alertService
        self.completion = completion
        self.analytics = analytics
        self.completionManager = completionManager
        self.keyboardManager = keyboardManager
        self.parsingErrorAnaliticManager = parsingErrorAnaliticManager
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
        analytics.sendEvent(.RQCreteOTP,
                            with: [AnalyticsKey.view: AnlyticsScreenEvent.OtpVC.rawValue])
        view?.showLoading()
        otpService.creteOTP { [weak self] result in
            switch result {
            case .success:
                self?.view?.hideLoading(animate: true)
                self?.updateTimerView()
                self?.createTimer()
                self?.analytics.sendEvent(.RQGoodCreteOTP,
                                          with: [AnalyticsKey.view: AnlyticsScreenEvent.OtpVC.rawValue])
                self?.analytics.sendEvent(.RSGoodCreteOTP,
                                          with: [AnalyticsKey.view: AnlyticsScreenEvent.OtpVC.rawValue])
            case .failure(let error):
                self?.parsingErrorAnaliticManager.sendAnaliticsError(error: error,
                                                                     type: .otp(type: .creteOTP))
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
        analytics.sendEvent(.TouchNext,
                            with: [AnalyticsKey.view: AnlyticsScreenEvent.OtpVC.rawValue])
        let otpHash = getHashCode(code: otpCode)
        view?.showLoading()
        analytics.sendEvent(.RQConfirmOTP,
                            with: [AnalyticsKey.view: AnlyticsScreenEvent.OtpVC.rawValue])
        analytics.sendEvent(.RSConfirmOTP,
                            with: [AnalyticsKey.view: AnlyticsScreenEvent.OtpVC.rawValue])
        otpService.confirmOTP(otpHash: otpHash) { [weak self]  result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.analytics.sendEvent(.RSGoodConfirmOTP,
                                         with: [AnalyticsKey.view: AnlyticsScreenEvent.OtpVC.rawValue])
                self.analytics.sendEvent(.RQGoodConfirmOTP,
                                         with: [AnalyticsKey.view: AnlyticsScreenEvent.OtpVC.rawValue])
                self.view?.hideKeyboard()
                self.closeWithSuccess()
            case .failure(let error):
                self.parsingErrorAnaliticManager.sendAnaliticsError(error: error,
                                                                    type: .otp(type: .confirmOTP))
                if error.represents(.incorrectCode) {
                    self.analytics.sendEvent(.RQFailConfirmOTP)
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.view?.hideLoading(animate: true)
                        self.view?.showError(with: Strings.TextField.Error.Wrong.title)
                    }
                } else if error.represents(.tryingError) {
                    self.alertService.show(on: self.view, type: .tryingError(back: {
                        self.dismissWithError(nil)
                    }))
                } else if error.represents(.timeOut) {
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
        analytics.sendEvent(.TouchBack, with: [AnalyticsKey.view: AnlyticsScreenEvent.OtpVC.rawValue])
        self.completionManager.dismissCloseAction(view)
    }
    
    func viewDidAppear() {
        analytics.sendEvent(.LCOTPViewAppeared)
    }
    
    func viewDidDisappear() {
        analytics.sendEvent(.LCOTPViewDisappeared)
    }
    
    private func closeWithSuccess() {
        view?.contentNavigationController?.popViewController(animated: false, completion: {
            self.completion?()
        })
    }
    
    private func dismissWithError(_ error: SDKError?) {
        if let error = error {
            self.completionManager.completeWithError(error)
        }
        self.alertService.close()
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

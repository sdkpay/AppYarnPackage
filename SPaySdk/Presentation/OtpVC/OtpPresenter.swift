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
    private var sec = 45
    private var countOfErrorPayment = 0
    private lazy var timer = Timer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    private var completion: Action?

    init(otpService: OTPService,
         userService: UserService,
         sdkManager: SDKManager,
         alertService: AlertService,
         completion: @escaping Action) {
        self.otpService = otpService
        self.userService = userService
        self.sdkManager = sdkManager
        self.alertService = alertService
        self.completion = completion
    }
    
    func viewDidLoad() {
        createTimer()
        getOTP()
        addObserver()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            view?.getKeyboardHeight(keyboardHeight: Int(keyboardHeight))
        }
    }
    
    func getOTP() {
        view?.showLoader()
        otpService.creteOTP(orderId: userService.user?.sessionId ?? "",
                            sessionId: userService.user?.sessionId ?? "",
                            paymentId: Int(userService.selectedCard?.paymentId ?? 0)) { error, mobilePhone in
            if let error {
                self.alertService.show(on: self.view, type: .defaultError(completion: { self.dismissWithError(error)}))
                self.view?.hideLoader()
                return
            }
            
            if let mobilePhone {
                self.view?.updateMobilePhone(phoneNumber: mobilePhone)
                self.view?.hideLoader()
            }
        }
    }
    
    func sendOTP(otpCode: String) {
        let otpHash = getHashCode(code: otpCode)
        view?.showLoader()
        otpService.confirmOTP(orderId: sdkManager.authInfo?.orderId ?? "",
                              orderHash: otpHash,
                              sessionId: userService.user?.sessionId ?? "") { errorCode, error in
            if let error {
                self.alertService.show(on: self.view, type: .defaultError(completion: { self.dismissWithError(error)}))
                self.view?.hideLoader()
                return
            }
            
            if errorCode == "5" {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.view?.hideLoading(animate: true)
                    self.view?.showError()
                    return
                }
            }
            
            if errorCode == "6" {
                self.alertService.show(on: self.view, type: .tryingError(back: {
                    self.view?.dismiss(animated: true)
                }))
                return
            }
            
            self.view?.hideKeyboard()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                guard let self = self else { return }
                self.closeWithSuccess()
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
        RunLoop.current.add(timer, forMode: .common)
    }
    
    @objc private func updateTime() {
        sec -= 1
        if sec < 0 {
            timer.invalidate()
            sec = 45
        } else {
            view?.updateTimer(sec: sec)
        }
    }
}

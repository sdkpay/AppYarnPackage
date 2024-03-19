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
    func otpFieldChanged()
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
    private let analytics: AnalyticsManager
    private let completionManager: CompletionManager
    private var timerManager: TimerManager
    
    private var state: OtpViewState = .waiting
    
    private var completion: Action?
    
    init(otpService: OTPService,
         userService: UserService,
         authManager: AuthManager,
         sdkManager: SDKManager,
         alertService: AlertService,
         analytics: AnalyticsManager,
         completionManager: CompletionManager,
         timerManager: TimerManager = DefaultTimerManager(),
         completion: @escaping Action) {
        self.otpService = otpService
        self.userService = userService
        self.authManager = authManager
        self.sdkManager = sdkManager
        self.alertService = alertService
        self.completion = completion
        self.analytics = analytics
        self.timerManager = timerManager
        self.completionManager = completionManager
    }
    
    func viewDidLoad() {
        timerManager.setup(sec: 45)
        timerManager.start()
        setState(.waiting)
        configViews()
    }
    
    private func configViews() {
        
        view?.updateMobilePhone(phoneNumber: otpService.otpModel?.mobilePhone ?? "none")
    }
    
    func createOTP() {
        
        timerManager.start()
        setState(.waiting)
        view?.setOtpTextFieldState(.empty)
        view?.setOtpError(nil)

        Task {
            do {
                
                await view?.showLoading()
                try await otpService.creteOTP()
                await view?.hideLoading(animate: true)
            } catch {
                if let error = error as? SDKError {
                    
                    self.completionManager.completeWithError(error)
                    
                    await view?.hideLoading(animate: true)
                    
                    if error.represents(.noInternetConnection) {
                        
                        let result = await alertService.show(on: view, type: .noInternet)
                        
                        switch result {
                        case .approve:
                            createOTP()
                        case .cancel:
                            dismissWithError(error)
                        }
                    } else {
                        
                        await alertService.show(on: view, type: .defaultError)
                        dismissWithError(error)
                    }
                } else {
                    self.completionManager.dismissCloseAction(view)
                }
            }
        }
    }
    
    func sendOTP(otpCode: String) {
        
        analytics.send(EventBuilder().with(base: .Touch).with(value: "Next").build(),
                       on: view?.analyticsName ?? .None)
        
        Task { @MainActor [view] in
            do {
                
                view?.showLoading()
                try await otpService.confirmOTP(code: otpCode,
                                                cardNumber: userService.selectedCard?.cardNumber ?? "")
                
                view?.hideLoading(animate: true)
                
                await self.view?.hideKeyboard()
                self.closeWithSuccess()
            } catch {
                
                setState(.error)
                
                if let error = error as? SDKError {
                    
                    self.completionManager.completeWithError(error)
                    
                    if error.represents(.incorrectCode) || error.represents(.timeOut) {
                        
                        self.view?.hideLoading(animate: true)
                        
                        self.view?.setOtpError(error.description)
                    } else if error.represents(.tryingError) {
                        
                        await alertService.show(on: view, type: .tryingError)
                        dismissWithError(nil)
                    } else {
                        
                        await alertService.show(on: view, type: .defaultError)
                        dismissWithError(error)
                    }
                }
            }
        }
    }
    
    func otpFieldChanged() {
        
        if state == .error {
            
            view?.setOtpError(nil)
            self.state = .waiting
        }
    }
    
    func viewDidAppear() {
    }
    
    func viewDidDisappear() {
    }
    
    func back() {
        analytics.send(EventBuilder().with(base: .Touch).with(value: "Back").build(),
                       on: view?.analyticsName ?? .None)
        self.completionManager.dismissCloseAction(view)
    }
    
    private func setState(_ state: OtpViewState) {
        
        self.state = state
        view?.setViewState(state)
        
        switch state {
        case .ready:
            
            view?.setOtpDescription(Strings.Otp.Time.Button.Repeat.isActive)
        case .waiting:
            
            timerManager.update { seconds in
                
                if seconds > 0 {
                    self.view?.setOtpDescription(Strings.Otp.Time.Button.Repeat.isNotActive(seconds))
                } else {
                    self.setState(.ready)
                }
            }
        case .error:
            
            return
        }
    }
    
    private func closeWithSuccess() {
        DispatchQueue.main.async {
            self.view?.contentNavigationController?.popViewController(animated: false, completion: {
                self.completion?()
            })
        }
    }
    
    private func dismissWithError(_ error: SDKError?) {
 
        self.completionManager.dismissCloseAction(view)
    }
}

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
    private let analytics: AnalyticsService
    private let completionManager: CompletionManager
    private var timerManager: TimerManager
    private let parsingErrorAnaliticManager: ParsingErrorAnaliticManager
    
    private var state: OtpViewState = .waiting
    
    private var completion: Action?
    
    init(otpService: OTPService,
         userService: UserService,
         authManager: AuthManager,
         sdkManager: SDKManager,
         alertService: AlertService,
         analytics: AnalyticsService,
         completionManager: CompletionManager,
         timerManager: TimerManager = DefaultTimerManager(),
         parsingErrorAnaliticManager: ParsingErrorAnaliticManager,
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
        self.parsingErrorAnaliticManager = parsingErrorAnaliticManager
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
        
        analytics.sendEvent(.RQCreteOTP,
                            with: [AnalyticsKey.View: AnlyticsScreenEvent.OtpVC.rawValue])
        
        Task {
            do {
                
                await view?.showLoading()
                try await otpService.creteOTP()
                await view?.hideLoading(animate: true)
                self.analytics.sendEvent(.RQGoodCreteOTP,
                                         with: [AnalyticsKey.View: AnlyticsScreenEvent.OtpVC.rawValue])
                self.analytics.sendEvent(.RSGoodCreteOTP,
                                         with: [AnalyticsKey.View: AnlyticsScreenEvent.OtpVC.rawValue])
            } catch {
                if let error = error as? SDKError {
                    
                    self.completionManager.completeWithError(error)
                    
                    parsingErrorAnaliticManager.sendAnaliticsError(error: error,
                                                                   type: .otp(type: .creteOTP))
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
        
        analytics.sendEvent(.TouchNext,
                            with: [AnalyticsKey.View: AnlyticsScreenEvent.OtpVC.rawValue])
        analytics.sendEvent(.RQConfirmOTP,
                            with: [AnalyticsKey.View: AnlyticsScreenEvent.OtpVC.rawValue])
        
        Task { @MainActor [view] in
            do {
                
                view?.showLoading()
                try await otpService.confirmOTP(code: otpCode,
                                                cardNumber: userService.selectedCard?.cardNumber ?? "")
                
                view?.hideLoading(animate: true)
                
                analytics.sendEvent(.RSGoodConfirmOTP,
                                    with: [
                                        AnalyticsKey.View: AnlyticsScreenEvent.OtpVC.rawValue
                                    ])
                analytics.sendEvent(.RQGoodConfirmOTP,
                                    with: [
                                        AnalyticsKey.View: AnlyticsScreenEvent.OtpVC.rawValue
                                    ])
                
                await self.view?.hideKeyboard()
                self.closeWithSuccess()
            } catch {
                
                setState(.error)
                
                if let error = error as? SDKError {
                    
                    self.completionManager.completeWithError(error)
                    
                    self.parsingErrorAnaliticManager.sendAnaliticsError(error: error,
                                                                        type: .otp(type: .confirmOTP))
                    
                    if error.represents(.incorrectCode) || error.represents(.timeOut) {
                        
                        self.analytics.sendEvent(.RQFailConfirmOTP)
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
        analytics.sendEvent(.LCOTPViewAppeared)
    }
    
    func viewDidDisappear() {
        timerManager.stop()
        analytics.sendEvent(.LCOTPViewDisappeared)
    }
    
    func back() {
        analytics.sendEvent(.TouchBack, with: [AnalyticsKey.View: AnlyticsScreenEvent.OtpVC.rawValue])
        self.completionManager.dismissCloseAction(view)
    }
    
    private func setState(_ state: OtpViewState) {
        
        self.state = state
        view?.setViewState(state)
        
        switch state {
        case .ready:
            
            view?.setOtpDescription(Strings.Time.Button.Repeat.isActive)
        case .waiting:
            
            timerManager.update { seconds in
                
                if seconds > 0 {
                    self.view?.setOtpDescription(Strings.Time.Button.Repeat.isNotActive(seconds))
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

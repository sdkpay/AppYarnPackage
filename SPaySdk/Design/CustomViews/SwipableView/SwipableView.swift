//
//  SwipableView.swift
//  SPaySdk
//
//  Created by Ипатов Александр Станиславович on 02.12.2023.
//

import UIKit

class SwipableView: UIView {
    
    private var initialCenter = CGPoint.zero
    
    var viewDismissAction: Action?
    
    init() {
        super.init(frame: .zero)
        let gesture = UIPanGestureRecognizer(target: self,
                                             action: #selector(wasDragged(gesture:)))
        self.addGestureRecognizer(gesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private
    func wasDragged(gesture: UIPanGestureRecognizer) {
            let location = gesture.location(in: superview)
            
            if gesture.state == .began {
                if initialCenter == CGPoint.zero {
                    initialCenter = self.center
                }
            } else {
                if initialCenter.x - location.x > 0 {
                    self.alpha = location.x / self.initialCenter.x
                } else {
                    self.alpha = ((superview?.bounds.width ?? 0) - location.x) / initialCenter.x
                }
                self.center.x = location.x
            }
            if gesture.state == .ended {
                let displacement = ((initialCenter.x - location.x) > 0) ? (initialCenter.x - location.x) : -(initialCenter.x - location.x)

                if displacement > self.bounds.width / 2.0 {
                    self.alpha = 0.0
                    self.viewDismissAction?()
                } else {
                    
                    UIView.animate(withDuration: 0.25) {
                        self.center = self.initialCenter
                        self.alpha = 1.0
                    }
                }
            }
        }
}

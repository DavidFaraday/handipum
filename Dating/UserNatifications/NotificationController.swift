//
//  NotificationController.swift
//  Dating
//
//  Created by David Kababyan on 17/02/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import JGProgressHUD

class NotificationController {
    
    let hud: JGProgressHUD
    let view: UIView
    
    init(_view: UIView) {
        self.view = _view
        hud = JGProgressHUD(style: .dark)
    }
    
    //MARK: - Show notifications
    func showNotification(text: String, isError: Bool) {
        
        if isError {
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
        } else {
            self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        }
        
        self.hud.textLabel.text = text
        self.hud.show(in: self.view)
        self.hud.dismiss(afterDelay: 2.0)
    }

}

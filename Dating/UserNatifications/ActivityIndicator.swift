//
//  ActivityIndicator.swift
//  Dating
//
//  Created by David Kababyan on 16/02/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import NVActivityIndicatorView

class ActivityIndicator {
    
    var activityIndicator: NVActivityIndicatorView?
    var view: UIView!
    
    init(_view: UIView) {
        self.view = _view
        setupActivityIndicator()
    }
    
    //MARK: - Activity indicator

    private func setupActivityIndicator() {
        
        let activityViewColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height / 2 - 30, width: 60, height: 60), type: .ballZigZag, color: activityViewColor, padding: nil)
    }
    
    func showLoadingIndicator() {
        
        if activityIndicator != nil {
            self.view.addSubview(activityIndicator!)
            activityIndicator!.startAnimating()
        }
    }
    
    func hideLoadingIndicator() {
        
        if activityIndicator != nil {
            activityIndicator!.removeFromSuperview()
            activityIndicator!.stopAnimating()
        }
    }

}

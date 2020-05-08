//
//  SampleCardOverlay.swift
//  Dating
//
//  Created by David Kababyan on 02/03/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit

class UserCardOverlay: UIView {
    
    static func left() -> UIView {
        let overlay = UIView()
        let leftTextView = SampleOverlayLabelView(withTitle: "NOPE",
                                                  color: .sampleRed,
                                                  rotation: CGFloat.pi/10)
        overlay.addSubview(leftTextView)
        leftTextView.anchor(top: overlay.topAnchor,
                            right: overlay.rightAnchor,
                            paddingTop: 30, paddingRight: 14)
        return overlay
    }
    
    static func up() -> UIView {
        let overlay = UIView()
        let upTextView = SampleOverlayLabelView(withTitle: "LOVE",
                                                color: .sampleBlue,
                                                rotation: -CGFloat.pi/20)
        overlay.addSubview(upTextView)
        upTextView.anchor(bottom: overlay.bottomAnchor, paddingBottom: 20)
        upTextView.centerXAnchor.constraint(equalTo: overlay.centerXAnchor).isActive = true
        return overlay
    }
    
    static func right() -> UIView {
        let overlay = UIView()
        let rightTextView = SampleOverlayLabelView(withTitle: "LIKE",
                                                   color: .sampleGreen,
                                                   rotation: -CGFloat.pi/10)
        overlay.addSubview(rightTextView)
        rightTextView.anchor(top: overlay.topAnchor,
                             left: overlay.leftAnchor,
                             paddingTop: 26,
                             paddingLeft: 14)
        return overlay
    }
}


private class SampleOverlayLabelView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    init(withTitle title: String, color: UIColor, rotation: CGFloat) {
        super.init(frame: CGRect.zero)
        layer.borderColor = color.cgColor
        layer.borderWidth = 4
        layer.cornerRadius = 4
        transform = CGAffineTransform(rotationAngle: rotation)
        
        addSubview(titleLabel)
        titleLabel.textColor = color
        titleLabel.attributedText = NSAttributedString(string: title,
                                                       attributes: NSAttributedString.Key.overlayAttributes)
        titleLabel.anchor(top: topAnchor,
                          left: leftAnchor,
                          bottom: bottomAnchor,
                          right: rightAnchor,
                          paddingLeft: 8,
                          paddingRight: 3)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
}

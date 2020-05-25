//
//  SampleCardOverlay.swift
//  Dating
//
//  Created by David Kababyan on 02/03/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit
import Shuffle_iOS

class UserCardOverlay: UIView {
    
    init(direction: SwipeDirection) {
      super.init(frame: .zero)
      switch direction {
      case .left:
        createLeftOverlay()
      case .right:
        createRightOverlay()
      default:
        break
      }
    }

    
    required init?(coder: NSCoder) {
      return nil
    }

    private func createLeftOverlay() {
      let leftTextView = SampleOverlayLabelView(withTitle: "NOPE",
                                                    color: .sampleRed,
                                                    rotation: CGFloat.pi/10)
      addSubview(leftTextView)
      leftTextView.anchor(top: topAnchor,
                          right: rightAnchor,
                          paddingTop: 30, paddingRight: 14)
    }

    
    private func createRightOverlay() {
      let rightTextView = SampleOverlayLabelView(withTitle: "LIKE",
                                                     color: .sampleGreen,
                                                     rotation: -CGFloat.pi/10)
      addSubview(rightTextView)
      rightTextView.anchor(top: topAnchor,
                           left: leftAnchor,
                           paddingTop: 26,
                           paddingLeft: 14)
    }

    //
//    static func left() -> UIView {
//        let overlay = UIView()
//        let leftTextView = SampleOverlayLabelView(withTitle: "NOPE",
//                                                  color: .sampleRed,
//                                                  rotation: CGFloat.pi/10)
//        overlay.addSubview(leftTextView)
//        leftTextView.anchor(top: overlay.topAnchor,
//                            right: overlay.rightAnchor,
//                            paddingTop: 30, paddingRight: 14)
//        return overlay
//    }
//    
//    
//    static func right() -> UIView {
//        let overlay = UIView()
//        let rightTextView = SampleOverlayLabelView(withTitle: "LIKE",
//                                                   color: .sampleGreen,
//                                                   rotation: -CGFloat.pi/10)
//        overlay.addSubview(rightTextView)
//        rightTextView.anchor(top: overlay.topAnchor,
//                             left: overlay.leftAnchor,
//                             paddingTop: 26,
//                             paddingLeft: 14)
//        return overlay
//    }
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

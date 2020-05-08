//
//  SwipeCard.swift
//  Dating
//
//  Created by David Kababyan on 02/03/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import Shuffle_iOS

class UserCard: SwipeCard {
    
    override var swipeDirections: [SwipeDirection] {
        return [.left, .right]
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        footerHeight = 80
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func overlay(forDirection direction: SwipeDirection) -> UIView? {
        switch direction {
        case .left:
            return UserCardOverlay.left()
        case.right:
            return UserCardOverlay.right()
        default:
            return nil
        }
    }
    
    func configure(withModel model: UserCardModel) {
        content = UserCardContentView(withImage: model.image)
        footer = UserCardFooterView(withTitle: "\(model.name), \(model.age)", subtitle: model.occupation)
    }
}




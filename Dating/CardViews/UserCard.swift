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
    
    
    
    func configure(withModel model: UserCardModel) {
        content = UserCardContentView(withImage: model.image)
        footer = UserCardFooterView(withTitle: "\(model.name), \(model.age)", subtitle: model.occupation)
    }
}




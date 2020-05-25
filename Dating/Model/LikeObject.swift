//
//  Like.swift
//  Dating
//
//  Created by David Kababyan on 03/05/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation

struct LikeObject {
    
    let id: String
    let userId: String
    let likedUserId: String
    let date: Date
    
    var dictionary : [String : Any] {
        return [kOBJECTID : id, kUSERID: userId, kLIKEDUSERID : likedUserId, kDATE : date]
    }
    
    func saveToFirestore() {
        FirebaseReference(.Like).document(self.id).setData(self.dictionary)
    }
}







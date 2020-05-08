//
//  MatchObject.swift
//  Dating
//
//  Created by David Kababyan on 02/05/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation

struct MatchObject {
    
    let id: String
    let memberIds: [String]
    
    var dictionary : [String : Any] {
         return [kOBJECTID : id, kMEMBERIDS : memberIds]
    }
    
    func saveToFirestore() {
        FirebaseReference(.Match).document(self.id).setData(self.dictionary)
    }
}

func saveMatchWith(userId: String) {
    
    let match = MatchObject(id: UUID().uuidString, memberIds: [FUser.currentId(), userId])
    match.saveToFirestore()
}


//
//  MatchObject.swift
//  Dating
//
//  Created by David Kababyan on 02/05/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import UIKit

struct MatchObject {
    
    let id: String
    let memberIds: [String]
    let date: Date
    
    var dictionary : [String : Any] {
        return [kOBJECTID : id, kMEMBERIDS : memberIds, kDATE : date]
    }

    
    func saveToFirestore() {
        FirebaseReference(.Match).document(self.id).setData(self.dictionary)
    }

}








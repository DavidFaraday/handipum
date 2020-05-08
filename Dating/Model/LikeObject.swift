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
    
    var dictionary : [String : Any] {
        return [kOBJECTID : id, kUSERID: userId, kLIKEDUSERID : likedUserId]
    }
    
    func saveToFirestore() {
        FirebaseReference(.Like).document(self.id).setData(self.dictionary)
    }
}


func checkIfUserLikedUs(userId: String, completion: @escaping (_ didLike: Bool) -> Void ) {
    
    FirebaseReference(.Like).whereField(kLIKEDUSERID, isEqualTo: FUser.currentId()).whereField(kUSERID, isEqualTo: userId).getDocuments { (snapshot, error) in
        
        guard let snapshot = snapshot else {  return }
        
        completion(!snapshot.isEmpty)
    }
    
}


func saveLikeToUser(userId: String) {
    
    if let currentUser = FUser.currentUser() {

        if !currentUser.likedIdArray!.contains(userId) {
            currentUser.likedIdArray!.append(userId)
            
            updateCurrentUserInFirestore(withValues: [kLIKEDIDARRAY: currentUser.likedIdArray!]) { (error) in
                print("updated likes with error ", error)
            }
        }
    }
}

func didLikeUserWith(userId: String) -> Bool {
    
    return FUser.currentUser()?.likedIdArray?.contains(userId) ?? false
}

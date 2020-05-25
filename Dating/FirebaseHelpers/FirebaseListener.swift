//
//  FirebaseListener.swift
//  Dating
//
//  Created by David Kababyan on 16/05/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import Firebase


class FirebaseListener {
    
    static let shared = FirebaseListener()
    
    private init() {}
    
    //MARK: - RecentChats
    func downloadRecentChatsFromFireStore(completion: @escaping (_ allRecents: [RecentChat]) -> Void) {
        
        FirebaseReference(.Recent).whereField(kSENDERID, isEqualTo: FUser.currentId()).addSnapshotListener() { (querySnapshot, error) in
        
            var recentChats: [RecentChat] = []

            guard let snapshot = querySnapshot else { return }
            
            if !snapshot.isEmpty {

                for recentDocument in snapshot.documents {

                    if recentDocument[kLASTMESSAGE] as! String != "" && recentDocument[kCHATROOMID] != nil && recentDocument[kOBJECTID] != nil {
                        
                        let recent = RecentChat(recentDocument.data())
                        recentChats.append(recent)
                        
                    }
                }

                recentChats.sort(by: { $0.date > $1.date })
                completion(recentChats)
            } else {
                completion(recentChats)
            }
        }
    }
    
    func updateRecents(chatRoomId: String, lastMessage: String) {
        print("last", lastMessage)
        FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {
                
                for recent in snapshot.documents {
                    
                    let recentChat = RecentChat(recent.data() )
                    
                    self.updateRecentItem(recent: recentChat, lastMessage: lastMessage)
                }
            }
        }
    }


    private func updateRecentItem(recent: RecentChat, lastMessage: String) {
            
        if recent.senderId != FUser.currentId() {
            recent.unreadCounter += 1
        }
        
        let values = [kLASTMESSAGE : lastMessage, kUNREADCOUNTER : recent.unreadCounter, kDATE : Date()] as [String : Any]
        
        FirebaseReference(.Recent).document(recent.objectId).updateData(values)
    }
    
    
    func resetRecentCounter(chatRoomId: String) {
        
        FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).whereField(kSENDERID, isEqualTo: FUser.currentId()).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {
                
                if let recentData = snapshot.documents.first?.data() {
                    let recent = RecentChat(recentData)
                    self.clearUnreadCounter(recent: recent)
                }
            }
        }
    }


    func clearUnreadCounter(recent: RecentChat) {
        
        let values = [kUNREADCOUNTER : 0] as [String : Any]
        
        FirebaseReference(.Recent).document(recent.objectId).updateData(values)
    }
    
    
    //MARK: - Match
    func downloadUserMatches(completion: @escaping (_ matchedUserIds: [String]) -> Void ) {
        
        //need to create index for ordering by date
        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        
        FirebaseReference(.Match).whereField(kMEMBERIDS, arrayContains: FUser.currentId()).whereField(kDATE, isGreaterThan: lastMonth).order(by: kDATE, descending: true).getDocuments { (snapshot, error) in
            
            var allMatchedIds: [String] = []
            
            guard let snapshot = snapshot else {  return }
            
            if !snapshot.isEmpty {
                
                for matchDictionary in snapshot.documents {
                    allMatchedIds += matchDictionary[kMEMBERIDS] as? [String] ?? [""]
                }
                
                completion(removerCurrentUserFrom(userIds: allMatchedIds))
            } else {
                print("No Matches found")
                completion(allMatchedIds)
            }
        }
    }
    
    func saveMatchWith(userId: String) {
         
        let match = MatchObject(id: UUID().uuidString, memberIds: [FUser.currentId(), userId], date: Date())
        match.saveToFirestore()
    }


    //MARK: - Likes
    func downloadUserLikes(completion: @escaping (_ matchedUserIds: [String]) -> Void ) {

        FirebaseReference(.Like).whereField(kLIKEDUSERID, isEqualTo: FUser.currentId()).getDocuments { (snapshot, error) in

            var allLikedIds: [String] = []
            
            guard let snapshot = snapshot else {
                completion(allLikedIds)
                return
            }
            
            if !snapshot.isEmpty {
                
                for likeDictionary in snapshot.documents {
                    allLikedIds.append(likeDictionary[kUSERID] as? String ?? "")
                }
                
                completion(allLikedIds)
            } else {
                print("No Likes found")
                completion(allLikedIds)
            }
        }
    }

    func checkIfUserLikedUs(userId: String, completion: @escaping (_ didLike: Bool) -> Void ) {
        
        FirebaseReference(.Like).whereField(kLIKEDUSERID, isEqualTo: FUser.currentId()).whereField(kUSERID, isEqualTo: userId).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else {  return }
            
            completion(!snapshot.isEmpty)
        }
        
    }
    
    //MARK: - FUsers
    func downloadCurrentUserFromFirebase(userId: String, email: String) {
        
        FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
            guard let snapshot = snapshot else {  return }
            
            if snapshot.exists {

                let user = FUser(_dictionary: snapshot.data()! as NSDictionary)
                user.saveUserLocally()
                
                //update email in case there was a change?
                user.updateCurrentUserInFirestore(withValues: [kEMAIL : email]) { (error) in
                    
                }
            } else {
                //first login save to firebase
                if let user = userDefaults.object(forKey: kCURRENTUSER) {
                    print("......", user)
                    FUser(_dictionary: user as! NSDictionary).saveUserToFirestore()
                }
            }
        }
    }

    func downloadUsersFromFirebase(isInitialLoad: Bool, limit: Int, lastDocumentSnapshot: DocumentSnapshot?, completion: @escaping (_ users: [FUser], _ snapshot: DocumentSnapshot?) -> Void ) {
        
        
        var query: Query!
        var users:[FUser] = []

        if isInitialLoad {

            query = FirebaseReference(.User).order(by: kREGISTEREDDATE, descending: false).limit(to: limit)
            print("First \(limit) users loading")
        } else {
            if lastDocumentSnapshot != nil {
                query = FirebaseReference(.User).order(by: kREGISTEREDDATE, descending: false).limit(to: limit).start(afterDocument: lastDocumentSnapshot!).limit(to: limit)
                print("Next \(limit) users loading")
            } else {
                print("last snap is nil")
            }
        }
        
        if query != nil {
            query.getDocuments { (snapshot, error) in
                
                guard let snapshot = snapshot else {  return }
                
                if !snapshot.isEmpty {

                    for userData in snapshot.documents {
                        
                        let userObject = userData.data() as NSDictionary
                        
                        //removed liked users
                        if !(FUser.currentUser()?.likedIdArray?.contains(userData[kOBJECTID] as! String) ?? false) && FUser.currentId() != userData[kOBJECTID] as! String {
                            users.append(FUser(_dictionary: userObject))//image placeholder here
                        }
                    }

                    completion(users, snapshot.documents.last!)

                } else {
                    print("no more users to fetch!")
                    completion(users, nil)
                }
            }
        } else {
            completion(users, nil)
        }
    }

    func downloadUserFromFirebase(withIds: [String], completion: @escaping (_ users: [FUser]) -> Void ) {

        var count = 0
        var usersArray: [FUser] = []
        
        //go through each user and download it from firestore
        for userId in withIds {
            
            FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
                
                guard let snapshot = snapshot else {  return }
                
                if snapshot.exists {

                    let user = FUser(_dictionary: snapshot.data()! as NSDictionary)
                    
                    usersArray.append(user)
                    count += 1
                    
                    if count == withIds.count {
                        //we have finished, return the array
                        completion(usersArray)
                    }

                    user.getUserAvatarFromFirestore { (success) in 

                    }

                } else {
                    completion(usersArray)
                }
            }
        }
    }


}

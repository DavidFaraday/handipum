//
//  GlobalFunctions.swift
//  Dating
//
//  Created by David Kababyan on 20/05/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import Firebase

//MARK: - Matches
func removerCurrentUserFrom(userIds: [String]) -> [String] {
    
    var allIds = userIds
    print("all ids are: ", allIds)
    print("current id is", FUser.currentId())
    
    for id in userIds {
        if id == FUser.currentId() {
            allIds.remove(at: allIds.firstIndex(of: id)!)
        }
    }
    
    print("filtered ids are", allIds)
    return allIds
}

//MARK: - Starting Chat
func startChat(user1: FUser, user2: FUser) -> String {

    let chatRoomId = chatRoomIdFrom(user1Id: user1.objectId, user2Id: user2.objectId)
        
    createRecentItems(chatRoomId: chatRoomId, users: [user1, user2])
    
    return chatRoomId
}


//MARK: - RecentChats
func createRecentItems(chatRoomId: String, users: [FUser]) {
    
    var memberIdsToCreateRecent = [users.first!.objectId, users.last!.objectId]
    
    //check if the user has recent with that chatRoom id, if no create one
    FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        
        guard let snapshot = snapshot else { return }
        
        if !snapshot.isEmpty {
            
            memberIdsToCreateRecent = removeMemberWhoHasRecent(snapshot: snapshot, memberIds: memberIdsToCreateRecent)
        }
        
        //create recents for remaining users
        for userId in memberIdsToCreateRecent {
            
            let senderUser = userId == FUser.currentId() ? users.first! : users.last!

            let receiverUser = userId == FUser.currentId() ? users.last! : users.first!
            
            
            let recentObject = RecentChat()
            
            recentObject.objectId = UUID().uuidString
            recentObject.chatRoomId = chatRoomId
            recentObject.senderId = senderUser.objectId
            recentObject.senderName = senderUser.username
            recentObject.receiverId = receiverUser.objectId
            recentObject.receiverName = receiverUser.username
            recentObject.date = Date()
            recentObject.memberIds = [senderUser.objectId, receiverUser.objectId]
            recentObject.lastMessage = ""
            recentObject.unreadCounter = 0
            recentObject.avatarLink = receiverUser.avatarLink
            
            recentObject.saveToFirestore()
        }
    }
 
}



func removeMemberWhoHasRecent(snapshot: QuerySnapshot, memberIds: [String]) -> [String] {
    
    var memberIdsToCreateRecent = memberIds

    for recentData in snapshot.documents {
        
        let currentRecent = recentData.data() as Dictionary
        
        //check if recent has userId
        if let currentUserId = currentRecent[kSENDERID] {

            //if the member has recent, remove it from array
            if memberIdsToCreateRecent.contains(currentUserId as! String) {

                memberIdsToCreateRecent.remove(at: memberIdsToCreateRecent.firstIndex(of: currentUserId as! String)!)
            }
        }
    }

    return memberIdsToCreateRecent
}

func chatRoomIdFrom(user1Id: String, user2Id: String) -> String {
    
    var chatRoomId = ""
    
    let value = user1Id.compare(user2Id).rawValue

    chatRoomId = value < 0 ? (user1Id + user2Id) : (user2Id + user1Id)

    return chatRoomId
}



//MARK: - Liks
func saveLikeToUser(userId: String) {
    
    if let currentUser = FUser.currentUser() {

        if !currentUser.likedIdArray!.contains(userId) {
            currentUser.likedIdArray!.append(userId)
            
            currentUser.updateCurrentUserInFirestore(withValues: [kLIKEDIDARRAY: currentUser.likedIdArray!]) { (error) in
                print("updated likes with error ", error)
            }
        }
    }
}

func didLikeUserWith(userId: String) -> Bool {
    
    return FUser.currentUser()?.likedIdArray?.contains(userId) ?? false
}

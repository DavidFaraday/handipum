//
//  IncomingMessage.swift
//  Dating
//
//  Created by David Kababyan on 18/05/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import MessageKit
import Firebase

class IncomingMessage {
    
    var messagesCollectionView: MessagesViewController
    
    
    init(collectionView_: MessagesViewController) {
        messagesCollectionView = collectionView_
    }
    
    
    //MARK: CreateMessage
    
    func createMessage(messageDictionary: [String: Any]) -> MKMessage? {
        
        let message = Message(dictionary: messageDictionary)

        let mkMessage = MKMessage(message: Message(dictionary: messageDictionary))

        if message.type == kPICTURE {
            
            let photoItem = PhotoMessage(width: message.photoWidth, height: message.photoHeight)
            
            mkMessage.photoItem = photoItem
            mkMessage.kind = MessageKind.photo(photoItem)

            FileStorage.downloadImage(imageUrl: messageDictionary[kMEDIAURL] as? String ?? "") { (image) in

                mkMessage.photoItem?.image = image
                self.messagesCollectionView.messagesCollectionView.reloadData()
            }
        }
        

        return mkMessage
    }

//    //MARK: Helper
//
//    func returnOutgoingStatusForUser(senderId: String) -> Bool {
//
//        return senderId == FUser.currentId()
//    }


}

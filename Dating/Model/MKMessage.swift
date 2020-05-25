//
//  MKMessage.swift
//  Dating
//
//  Created by David Kababyan on 20/05/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import MessageKit

class MKMessage: NSObject, MessageType {
    
    var messageId: String
    var kind: MessageKind
    var sentDate: Date
    var incoming: Bool
    var mksender: MKSender
    var sender: SenderType { return mksender }
    var senderInitials: String

    var photoItem: PhotoMessage?
    var status: String

    init(message: Message) {

        self.messageId = message.id

        self.mksender = MKSender(senderId: message.senderId, displayName: message.senderName)
        self.status = message.status

        switch message.type {
            case kTEXT:
                self.kind = MessageKind.text(message.message)

//            case kPICTURE:
//                
////                let photoItem = PhotoMessage(width: message.photoWidth, height: message.photoHeight)
//                
//                
//                self.kind = MessageKind.photo(photoItem)
////                self.photoItem = photoItem

            default:
                self.kind = MessageKind.text(message.message)
        }

        self.senderInitials = message.senderInitials
        self.sentDate = message.sentDate
        self.incoming = FUser.currentId() != mksender.senderId
    }
}

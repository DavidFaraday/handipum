//
//  MessageDefaults.swift
//  Dating
//
//  Created by David Kababyan on 17/05/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import UIKit
import MessageKit

enum MessageDefaults {

    // Bubble
    static let bubbleColorOutgoing = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
    static let bubbleColorIncoming = UIColor(red: 230/255, green: 229/255, blue: 234/255, alpha: 1.0)

}


struct MKSender: SenderType, Equatable {

    var senderId: String
    var displayName: String
}

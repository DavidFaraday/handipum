//
//  PushNotifications.swift
//  Dating
//
//  Created by David Kababyan on 23/05/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation

class PushNotificationService {
    
    static let shared = PushNotificationService()
    
    private init() {}
    
    func sendPushNotificationTo(userIds: [String], body: String) {
        
        FirebaseListener.shared.downloadUserFromFirebase(withIds: userIds) { (users) in
            
            for user in users {
                if let pushId = user.pushId {
                    self.sendMessageToUser(to: pushId, title: user.username, body: body)
                }
            }
        }
    }

    private func sendMessageToUser(to token: String, title: String, body: String) {

        let urlString = "https://fcm.googleapis.com/fcm/send"
        
        let url = NSURL(string: urlString)!
        
        let paramString: [String : Any] = ["to" : token,
                                           "notification" :
                                            ["title" : title,
                                             "body" : body,
                                             "badge" : "1",
                                             "sound" : "default"
                                            ],
                                           "data" : ["user cool" : "yo wazuup"] //this is to pass extra info with message
        ]
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key= \(kSERVERKEY)", forHTTPHeaderField: "Authorization")
        
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print("error sending mess", err.debugDescription)
            }
        }
        task.resume()
    }
}

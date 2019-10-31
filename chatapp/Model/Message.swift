//
//  Message.swift
//  chatapp
//
//  Created by Joey Kraus on 28/07/2019.
//  Copyright © 2019 Joey Kraus. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    
    var imageUrl: String?
    
    var imageHeight:NSNumber?
    var imageWidth: NSNumber?
    
    var videoUrl: String?
    
    func chatPartnerId() -> String?{
        //currentuser is the user that is signd in currently
        return fromId == Auth.auth().currentUser?.uid ? toId: fromId
        
       
       /* if fromId == Auth.auth().currentUser?.uid{
            return toId!
        }else{
            return fromId!
        }*/
        
    }
    init(dictionary: [String:AnyObject]){
        super.init()
        
        fromId = dictionary["fromId"] as? String
         text = dictionary["text"] as? String
         toId = dictionary["toId"] as? String
         timestamp = dictionary["timestamp"] as? NSNumber
        imageUrl = dictionary["imageUrl"] as? String
         imageWidth = dictionary["imageWidth"] as? NSNumber
         imageHeight = dictionary["imageHeight"] as? NSNumber
        
        videoUrl = dictionary["videoUrl"] as? String
    }

}

//
//  PushNotificationHandler.swift
//  WingsPushSDK
//
//  Created by Ярослав Стрельников on 02.08.2022.
//  Copyright © 2022 Wings Solutions. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

class PushNotificationHandler: NSObject {
    static let shared: PushNotificationHandler = PushNotificationHandler()
    
    func sheduleNotification(withJSON json: Dictionary<String, Any>) {
        guard let data = json["data"] as? Dictionary<String, Any> else { return }
        guard let messageId = json["message_id"] as? String else { return }
        guard let to = json["to"] as? String else { return }

        let content = UNMutableNotificationContent()
        content.title = data["title"] as? String ?? "empty"
        content.body = data["body"] as? String ?? "empty"
        content.sound = .default
        content.categoryIdentifier = "\(data["click_action"] as? String ?? "empty")_local"
        content.subtitle = "to: \(to)"

        content.userInfo = [
            "to": to,
            "message-id": messageId,
            "custom-data": [
                "content_available": data["content_available"] as? Bool ?? false,
                "icon-image-url": "https://is2-ssl.mzstatic.com/image/thumb/Purple125/v4/49/93/f7/4993f785-9ee6-deed-bcac-b3c75df649e5/AppIcon-0-0-1x_U007emarketing-0-0-0-10-0-0-sRGB-0-0-0-GLES2_U002c0-512MB-85-220-0-0.png/1200x630wa.png",
                "channel": "UDP"
            ]
        ]
        
        if let fileUrl = URL(string: "https://is2-ssl.mzstatic.com/image/thumb/Purple125/v4/49/93/f7/4993f785-9ee6-deed-bcac-b3c75df649e5/AppIcon-0-0-1x_U007emarketing-0-0-0-10-0-0-sRGB-0-0-0-GLES2_U002c0-512MB-85-220-0-0.png/1200x630wa.png") {
            if let imageData = try? Data(contentsOf: fileUrl) {
                if let attachment = UNNotificationAttachment.saveImageToDisk(fileIdentifier: "image.jpg", data: imageData, options: nil) {
                    content.attachments = [attachment]
                }
            }
        }

        var trigger: UNNotificationTrigger?
        trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.001, repeats: false)
        content.threadIdentifier = "UDP Messages"

        if let trigger = trigger {
            let request = UNNotificationRequest(identifier: messageId, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print(error)
                }
            }
        }
    }
}

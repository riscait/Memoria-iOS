//
//  NotificationService.swift
//  NotificationService
//
//  Created by 村松龍之介 on 2019/05/06.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import UserNotifications

final class NotificationService: UNNotificationServiceExtension {

    struct URLAttachment {
        let fileURL: URL
        let type: String
        
        init?(_ object: [String: String]) {
            guard let urlString = object["url"],
                let fileURL = URL(string: urlString),
                let type = object["type"] else { return nil }
            self.fileURL = fileURL
            self.type = type
        }
    }

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = request.content.mutableCopy() as? UNMutableNotificationContent
        
        guard let object = request.content.userInfo["rpr_attachment"] as? [String: String],
            let urlAttachment = URLAttachment(object) else {
                contentHandler(self.bestAttemptContent!)
                return
        }
        URLSession.shared.downloadTask(with: urlAttachment.fileURL) { (location, response, error) in
            if let location = location {
                let fileName = UUID().uuidString + "." + urlAttachment.type
                let tmpFile = "file://".appending(NSTemporaryDirectory()).appending(fileName)
                let tmpUrl = URL(string: tmpFile)!
                try? FileManager.default.moveItem(at: location, to: tmpUrl)
                
                if let attachment = try? UNNotificationAttachment(identifier: "IDENTIFIER", url: tmpUrl, options: nil) {
                    self.bestAttemptContent?.attachments = [attachment]
                }
            }
            contentHandler(self.bestAttemptContent!)
            }.resume()
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}

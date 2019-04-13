//
//  EventTrackable.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/04/12.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import Foundation
import Repro

enum SharingSNS: String {
    case twitter
}

protocol EventTrackable {}

/// EventTrackableに適合すれば使えるデフォルト実装
extension EventTrackable {
    
    /// ユーザーがSNSにシェアしたことを送信する
    ///
    /// - Parameters:
    ///   - contentName: 何をシェアしたか
    ///   - serviceName: 何のSNSか
    func trackShare(contentName: String,
                    contentID: String,
                    serviceName: SharingSNS) {
        let className = String(describing: type(of: self))
        
        let properties = RPRShareProperties()
        
        properties.contentCategory = className
        properties.contentName = contentName
        properties.contentID = contentID
        properties.serviceName = serviceName.rawValue
        
        Repro.trackShare(properties)
        
        Log.info("Shared to \(serviceName.rawValue)")
    }
    
    /// ユーザーが記念日を登録したことを送信する
    ///
    /// - Parameters:
    ///   - eventName: カスタムイベント名
    ///   - properties: 任意のプロパティ
    func trackAddAnniversary(eventName: String, annivDate: Date, annivCategory: AnnivType)  {
        
        let properties: [String : Any] =  [
            "Anniversary date": annivDate,
            "Anniversary category": annivCategory.description
        ]
        
        Repro.track("Add Anniversary", properties: properties)
        
        Log.info("Tracked \(eventName) with \(properties)")
    }
    
    /// ユーザーがギフトを登録したことを送信する
    ///
    /// - Parameters:
    ///   - eventName: カスタムイベント名
    ///   - properties: 任意のプロパティ
    func trackAddGift(annivName: String, isReceived: Bool, goodsName: String, giftDate: Date?)  {
        
        let properties: [String : Any] =  [
            "Anniversary name": annivName,
            "Gift is received?": isReceived,
            "Goods name": goodsName,
            "Gift date": giftDate as Any,
        ]
        
        Repro.track("Add Gift", properties: properties)
        
        Log.info("Tracked Gift with \(properties)")
    }
    
    /// 局所的なカスタムイベントを送信する
    ///
    /// - Parameters:
    ///   - eventName: カスタムイベント名
    ///   - properties: 任意のプロパティ
    func trackEvent(eventName: String, properties: [String: Any])  {
        
        Repro.track(eventName, properties: properties)
        
        Log.info("Tracked \(eventName) with \(properties)")
    }
}

/// 画面名（クラス）をselfで取得するためにUIViewControllerに限定したデフォルト実装
extension EventTrackable where Self: UIViewController {
    /// ユーザーが開いた画面をトラッキングする
    func trackScreen() {
        let className = String(describing: type(of: self))
        
        Repro.track(className, properties: nil)
        
        Log.info("\(className) was displayed")
    }
}

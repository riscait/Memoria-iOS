//
//  StoreReviewRequestable.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/04/26.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import Foundation
import StoreKit

/// App Storeでのレビューを依頼する際のユーザーアクションの種類
enum StoreReviewAction {
    case addedAnniv
    case addedGift
    
    /// UserDefaultsに使うforKeyのString
    var keyName: String {
        switch self {
        case .addedAnniv:
            return UserDefaultsKey.numberOfAddedAnnivs.rawValue
        case .addedGift:
            return UserDefaultsKey.numberOfAddedGifts.rawValue
        }
    }
    
    /// 各ユーザーアクションごとの条件の閾値
    var threshold: Int {
        switch self {
        case .addedAnniv, .addedGift:
            return 3
        }
    }
}

/// App Storeでのレビューを訴求するためのプロトコル
protocol StoreReviewRequestable: AnyObject {}
extension StoreReviewRequestable {
    
    var thresholdOfAppLaunchCount: Int { return 5 }
    
    /// ユーザーアクションごとの条件と起動回数の条件を満たしていれば、AppStoreでのレビュー依頼を試みる
    ///
    /// - Parameter type: ユーザーアクションの種類
    func requestStoreReview(by action: StoreReviewAction) {
        let userDefaults = UserDefaults.standard
        
        if userDefaults.integer(forKey: action.keyName) > action.threshold,
            userDefaults.integer(forKey: UserDefaultsKey.launchCount.rawValue) > thresholdOfAppLaunchCount {
            SKStoreReviewController.requestReview()
        }
    }
}

//
//  StoreReviewRequestable.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/04/26.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import Foundation
import StoreKit

protocol StoreReviewRequestable: AnyObject {}

extension StoreReviewRequestable {
    
    var thresholdOfAppLaunchCount: Int { return 5 }
    
    /// 記念日を追加した回数と起動回数の条件を満たしていれば、AppStoreでのレビュー依頼を試みる
    func requestStoreReviewWhenAddedAnniv() {
        
        let thresholdOfAddedAnnivCount = 3
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.integer(forKey: "numberOfAddedAnniv") > thresholdOfAddedAnnivCount,
            userDefaults.integer(forKey: "launchCount") > thresholdOfAppLaunchCount {
            SKStoreReviewController.requestReview()
        }
    }
    
    /// ギフトを追加した回数と起動回数の条件を満たしていれば、AppStoreでのレビュー依頼を試みる
    func requestStoreReviewWhenAddedGift() {
        
        let thresholdOfAddedGiftCount = 3
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.integer(forKey: "numberOfAddedGift") > thresholdOfAddedGiftCount,
            userDefaults.integer(forKey: "launchCount") > thresholdOfAppLaunchCount {
            SKStoreReviewController.requestReview()
        }
    }
}

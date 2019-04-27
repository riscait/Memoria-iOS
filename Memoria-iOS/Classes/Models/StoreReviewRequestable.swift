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
    
    /// ５回以上起動しており、閾値を超えていればレビュー依頼をする
    ///
    /// - Parameters:
    ///   - numberOfTimes: 判定に使う回数
    ///   - threshold: 閾値
    func requestStoreReview(numberOfTimes: Int, threshold: Int) {
        let userDefaults = UserDefaults.standard
        
        if userDefaults.integer(forKey: "launchCount") > 5,
            numberOfTimes >= threshold {
            SKStoreReviewController.requestReview()
        }
    }
}

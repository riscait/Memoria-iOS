//
//  AppInfo.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/07.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import Foundation

struct AppInfo {
    
    static func getVersion() -> String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    static func getBuild() -> String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
}

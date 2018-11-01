//
//  AppDelegate.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/10/25.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var db: Firestore!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        db = Firestore.firestore()

        doFirstLaunch()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    /// 初回起動時のみに実行される関数
    private func doFirstLaunch() {
        // UserDefaults のインスタンス
        let userDefaults = UserDefaults.standard
        let launchCount = "launchCount"
        
        // デフォルト値を設定
        userDefaults.register(defaults: [launchCount: 0])
        
        if userDefaults.integer(forKey: launchCount) == 0 {
            print("初回起動です。")
            // ユニークIDを生成して永続化
            let uuid = UUID().uuidString
            userDefaults.set(uuid, forKey: "uuid")
            print("UUIDを生成しました: \(uuid)")
            // 初回起動フラグをオフにする
            userDefaults.set(1, forKey: launchCount)
        } else {
            let n = userDefaults.integer(forKey: launchCount) + 1
            userDefaults.set(n, forKey: launchCount)
            print("\(n)回目以降の起動です。\nUUID: \(userDefaults.string(forKey: "uuid")!)")
        }
    }
}


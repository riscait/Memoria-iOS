//
//  AppDelegate.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/10/25.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import Repro

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // 永続化用 UserDefaults
    let userDefaults = UserDefaults.standard

    override init() {
        super.init()
        // FirebaseApp オブジェクトを初期化
        FirebaseApp.configure()
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        createUUIDandLaunchCount()
        
        Repro.setup(SecretKeys.reproSDK)
        
        registerUserNotification(application)
        // プッシュ通知で付いたバッジを無条件で外すため
        // FIXME: 今後、他の用途でバッジを使うときにはこちらは削除する
        application.applicationIconBadgeNumber = 0
        
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
    
    // 通知の許可を得た場合に実行
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // デバイストークンの取得に成功した場合にReproにデバイストークンを渡す
        Repro.setPushDeviceToken(deviceToken)
    }

    // 通知の許可を得ることに失敗したとき
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Log.warn("Remote Notification Error: \(error)")
    }
    /// 初回起動時のみに実行される関数
    private func createUUIDandLaunchCount() {
        let firstLaunch = 0
        
        if userDefaults.integer(forKey: UserDefaultsKey.launchCount.rawValue) == firstLaunch {
            Log.info("初回起動です。")
            // ユニークIDを生成して永続化
            let uuid = UUID().uuidString
            userDefaults.set(uuid, forKey: UserDefaultsKey.uuid.rawValue)
            Log.info("UUIDを生成: \(uuid)")
            // 初回起動フラグをオフにする
            userDefaults.set(firstLaunch.incremented, forKey: UserDefaultsKey.launchCount.rawValue)
            
        } else {
            let newLaunchCount = userDefaults.integer(forKey: UserDefaultsKey.launchCount.rawValue).incremented
            userDefaults.set(newLaunchCount, forKey: UserDefaultsKey.launchCount.rawValue)
            Log.info("\(newLaunchCount)回目の起動 \nUUID: \(userDefaults.string(forKey: UserDefaultsKey.uuid.rawValue)!)")
        }
    }
    
}

// MARK: - UNUserNotificationCenter Delegate
extension AppDelegate: UNUserNotificationCenterDelegate, EventTrackable {
    /// ユーザー通知の許可を求める
    private func registerUserNotification(_ app: UIApplication) {
        let center = UNUserNotificationCenter.current()
        UNUserNotificationCenter.current().delegate = self
        center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
            if let error = error {
                Log.warn(error.localizedDescription)
                return
            }
            if granted {
                Log.info("ユーザー通知が許可されました")
                self.trackEvent(eventName: "Granted UserNotification")
                
            } else {
                Log.info("ユーザー通知が拒否されました")
                self.trackEvent(eventName: "Denied UserNotification")
            }
        }
        app.registerForRemoteNotifications()
    }
}

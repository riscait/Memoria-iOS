//
//  TabBarController.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/23.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

import Firebase

class TabBarController: UITabBarController {
    
    enum Key: String {
        case isFinishedTutorial
        case isFinishedMigration210
    }

    var handle: AuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let userDefaults = UserDefaults.standard
        // START: Firebase認証リスナー
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                print("""
                    Firebase認証リスナー登録
                    ユーザーID: \(user.uid)
                    メールアドレス: \(user.email ?? "nil")
                    画像URL: \(String(describing: user.photoURL))
                    """)
                // UserDefaultsのデフォルト登録
                userDefaults.register(defaults: [Key.isFinishedMigration210.rawValue : false])
                // 初回起動判定
                if !userDefaults.bool(forKey: "isFinishedTutorial") {
                    print("初回起動です!")
                    // welcome画面へ遷移
                    let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
                    let nextView = storyboard.instantiateInitialViewController()
                    self.present(nextView!, animated: true, completion: nil)
                } else if !(userDefaults.bool(forKey: Key.isFinishedMigration210.rawValue)) {
                    print("マイグレーションが必要")
                    let storyboard = UIStoryboard(name: "Migration", bundle: nil)
                    let MigrationVC = storyboard.instantiateInitialViewController() as! MigrationVC
                    self.present(MigrationVC, animated: true) {
                        MigrationVC.startMigration()
                    }
                }
            } else {
                // 未ログイン状態なら、ログイン画面へ遷移
                let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
                let viewController = storyboard.instantiateInitialViewController()
                self.present(viewController!, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Firebase認証リスナーを破棄
        Auth.auth().removeStateDidChangeListener(handle!)
    }    
}

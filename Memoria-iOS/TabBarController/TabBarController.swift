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
    
    var handle: AuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITabBar.appearance().tintColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        UITabBar.appearance().backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // START: Firebase認証リスナー
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                print("ユーザーID: " + user.uid)
                print("メールアドレス: \(String(describing: user.email))")
                print("画像URL: \(String(describing: user.photoURL))")
                // 初回起動判定
                if !UserDefaults.standard.bool(forKey: "isFinishedTutorial") {
                    print("初回起動です!")
                    // welcome画面へ遷移
                    let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
                    let nextView = storyboard.instantiateInitialViewController()
                    self.present(nextView!, animated: true, completion: nil)
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
    
    override func viewDidAppear(_ animated: Bool) {
    }
}

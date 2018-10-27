//
//  AnniversaryViewController.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/10/27.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class AnniversaryViewController: UICollectionViewController {

    var querySnapshot: QuerySnapshot?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // 連絡先情報のアクセス権を調べてOKなら連絡先情報を取り込む
        let contactAccess = ContactAccess()
        if contactAccess.checkStatus() {
            contactAccess.accessContact()
        }
        
        let db = Firestore.firestore()
        
        let userDefaults = UserDefaults.standard
        guard let uuid = userDefaults.string(forKey: "uuid") else { return }
        
        // DBの連絡先誕生日データを読み込む
        let contactBirthdayRef = db.collection("users").document(uuid).collection("contactBirthday")
        contactBirthdayRef.getDocuments() { querySnapshot, error in
            if let error = error {
                print("ドキュメントの検索に失敗しました: \(error)")
            } else {
                print("ドキュメントの検索が成功しました: \(querySnapshot?.count ?? 0)")
                self.querySnapshot = querySnapshot
            }
        }
        // Do any additional setup after loading the view.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    /// CollectionViewのセクション数を返す
    ///
    /// - Parameter collectionView: AnniversaryViewController
    /// - Returns: セクションの数
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // TODO: セクションの数を設定する
        return 1
    }

    /// CollectionViewのアイテム数を返す
    ///
    /// - Parameters:
    ///   - collectionView: AnniversaryViewController
    ///   - section: セクション番号
    /// - Returns: アイテム数
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let documentsCount = querySnapshot?.count else {
            print("ドキュメントは見つかりません。アイテム数は0になります")
            return 1
        }
        
        return documentsCount
    }

    /// CollectionViewCellを設定する
    ///
    /// - Parameters:
    ///   - collectionView: AnniversaryViewController
    ///   - indexPath: セルNo
    /// - Returns: CollectionViewCell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "anniversaryCell", for: indexPath)
        
//        querySnapshot.documents.flatMap({
//            $0.data().flatMap({ (data) in
//                return City(dictionary: data)
//            })
//        }) {
//            print("City: \(city)")
//            } else {
//            print("Document does not exist")
//            })
        // 存在するドキュメントの数だけ繰り返す
//        for (index, document) in querySnapshot.documents.enumerated() {
//            let int = document.data().
//        }
//        (cell.viewWithTag(1) as! UILabel).text = (querySnapshot.documents[0].data()["givenName"] as! String)
        (cell.viewWithTag(1) as! UILabel).text = "ABC"
        print("リターンセルします！！！")
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

//
//  GiftListModel.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/03/21.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import Foundation
import Firebase

protocol GiftListModelInput {
    func startFetch(completion: @escaping ([Gift]) -> ())
    func stopFetch()
}

final class GiftListModel: GiftListModelInput {
    /// ギフトデータの変更を監視するリスナー登録
    private var listenerRegistration: ListenerRegistration?
    /// ギフトのデータをフェッチする
    func startFetch(completion: @escaping ([Gift]) -> ()) {
        let filteredCollection = GiftDAO.getQuery(whereField: "isHidden", equalTo: false)
        // giftコレクションの変更を監視するリスナー登録
        listenerRegistration = filteredCollection?.addSnapshotListener { snapshot, error in
            if let error = error {
                Log.warn(error.localizedDescription)
                return
            }
            guard let snapshot = snapshot else { return }
            
            var gifts = [Gift]()
            for document in snapshot.documents {
                guard let gift = Gift(dictionary: document.data()) else { continue }
                gifts.append(gift)
            }
            // 日付順に並び替えて返却する
            // 日付未定のものは100年後として比較することで一番上になも位置付ける
            let future = Calendar.current.date(byAdding: .year, value: 100, to: Date())!
            gifts.sort(by: { $0.date?.dateValue() ?? future > $1.date?.dateValue() ?? future })
            // 処理が終了したらデータをコールバックで返す
            completion(gifts)
        }
    }
    /// リスナーを破棄する
    func stopFetch() {
        listenerRegistration?.remove()
    }
}

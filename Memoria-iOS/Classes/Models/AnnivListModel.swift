//
//  AnnivListModel.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/03/14.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import Foundation
import Firebase

protocol AnnivListModelInput {
    func startFetchAnnivs(completion: @escaping ([Anniv], [Anniv]) -> ())
    func stopFetchAnnivs()
}

final class AnnivListModel: AnnivListModelInput {
    /// 記念日データの変更を監視するリスナー登録
    var listenerRegistration: ListenerRegistration?
    /// 記念日の更新を監視するリスナー登録
    func startFetchAnnivs(completion: @escaping ([Anniv], [Anniv]) -> ()) {
        let filteredCollection = AnnivDAO.getQuery(whereField: "isHidden", equalTo: false)
        // anniversaryコレクションの変更を監視するリスナー登録
        listenerRegistration = filteredCollection?.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                    print("ドキュメント取得エラー: \(error!)")
                    return
            }
            var notFinishedAnnivs = [Anniv]()
            var finishedAnnivs = [Anniv]()
            // 記念日データが入ったドキュメントの数だけ繰り返す
            snapshot.documents.forEach { doc in
                // ドキュメントから記念日データを取り出すし、独自データモデル化
                guard var anniv = Anniv(dictionary: doc.data()) else { return }
                // 日付から次の記念日までの残日数を計算
                let remainingDays = DateDifferenceCalculator.getDifference(from: anniv.date.dateValue(), isAnnualy: anniv.isAnnualy)
                // 記念日データに残日数を追加
                anniv.remainingDays = remainingDays
                // 残日数も含めた記念日データをローカル配列に記憶
                if remainingDays >= 0 || anniv.isAnnualy {
                    notFinishedAnnivs.append(anniv)
                } else {
                    finishedAnnivs.append(anniv)
                }
            }
            // 記念日までの残日数順で並び替える
            notFinishedAnnivs.sort(by: { ($0.remainingDays!) < ($1.remainingDays!) })
            finishedAnnivs.sort(by: { ($0.remainingDays!) < ($1.remainingDays!) })
            // 昨日の記念日を一番後ろに移動する
            let yesterdays = notFinishedAnnivs.filter { $0.remainingDays == -1 }
            let otherDays = notFinishedAnnivs.filter { $0.remainingDays != -1 }
            notFinishedAnnivs = otherDays + yesterdays
            // 処理が終了したら記念日データをコールバックで返す
            completion(notFinishedAnnivs, finishedAnnivs)
        }
    }
    /// 記念日監視リスナーを破棄する
    func stopFetchAnnivs() {
        listenerRegistration?.remove()
    }
}

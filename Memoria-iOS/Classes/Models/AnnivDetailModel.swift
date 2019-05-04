//
//  AnnivDetailModel.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/03/16.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import Foundation
import Firebase

protocol AnnivDetailModelInput {
    func startFetchAnnivAndGifts(anniv: Anniv, completion: @escaping (Anniv, [[String: Any]]) -> ())
    func stopFetchAnnivAndGifts()
}

final class AnnivDetailModel: AnnivDetailModelInput {
    /// 記念日データの変更を監視するリスナー登録
    private var listenerRegistration: ListenerRegistration?
    /// 記念日の更新を監視し、記念日とギフト情報を取得するリスナー登録
    func startFetchAnnivAndGifts(anniv: Anniv, completion: @escaping (Anniv, [[String : Any]]) -> ()) {
        let filteredCollection = AnnivDAO.getQuery(whereField: "id", equalTo: anniv.id)
        // anniversaryコレクションの変更を監視するリスナー登録
        listenerRegistration = filteredCollection?.addSnapshotListener { snapshot, error in
            if let error = error {
                Log.warn(error.localizedDescription)
                return
            }
            guard let data = snapshot?.documents.first?.data(),
                var anniv = Anniv(dictionary: data) else { return }
            // 残日数を追加
            anniv.remainingDays = AnnivUtil.getRemainingDays(until: anniv.date.dateValue(), isAnnualy: anniv.isAnnualy)
            var gifts: [[String: Any]] = []
            let searchKey: String
            
            switch anniv.category {
            case .anniv:
                searchKey = anniv.title!
            case .birthday:
                searchKey = String(format: "fullName".localized,
                                      arguments: [anniv.familyName ?? "", anniv.givenName ?? ""])
                }
            self.searchGift(with: searchKey, for: anniv.category) { result in
                gifts = result
                completion(anniv, gifts)
            }
        }
    }
    /// リスナー登録を破棄
    func stopFetchAnnivAndGifts() {
        listenerRegistration?.remove()
    }
}

private extension AnnivDetailModel {
    /// ギフトを検索する
    private func searchGift(with searchKey: String,
                            for annivCategory: AnnivType,
                            completion: @escaping ([[String: Any]]) -> Void) {
        let whereField: String
        switch annivCategory {
        case .anniv: whereField = "anniversaryName"
        case .birthday: whereField = "personName"
        }
        
        var gifts: [[String: Any]] = []
        let query = GiftDAO.getQuery(whereField: whereField, equalTo: searchKey)
        query?.getDocuments { (querySnapshot, error) in
            if let error = error {
                Log.warn(error.localizedDescription)
                return
            }
            guard let documents = querySnapshot?.documents else { return }
            documents.forEach { gift in
                gifts.append(["id": gift.data()["id"] as! String,
                              "personName": gift.data()["personName"] as! String,
                              "goods": gift.data()["goods"] as! String,
                              "anniversaryName": gift.data()["anniversaryName"] as! String,
                              "isReceived": gift.data()["isReceived"] as! Bool])
            }
            completion(gifts)
        }
    }
}

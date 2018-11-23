//
//  AnniversaryDetailVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/09.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit
import Firebase

final class AnniversaryDetailVC: UIViewController {

    /// 星座を列挙
    enum StarSign: String {
        case aries
        case taurus
        case gemini
        case cancer
        case leo
        case virgo
        case libra
        case scorpio
        case sagittarius
        case capricorn
        case aquarius
        case pisces
        
        // 値をローカライズして返す
        func localizedString() -> String {
            return NSLocalizedString(self.rawValue, comment: "")
        }
    }
    /// 十二支を列挙
    enum ChineseZodiacSign: String {
        case rat
        case ox
        case tiger
        case rabbit
        case dragon
        case snake
        case horse
        case sheep
        case monkey
        case rooster
        case dog
        case pig
        
        // 値をローカライズして返す
        func localizedString() -> String {
            let headChar = self.rawValue.prefix(1).uppercased()
            let others = self.rawValue.suffix(self.rawValue.count - 1)
            let signString = "chineseZodiacSign\(headChar)\(others)"
            print(signString)
            return NSLocalizedString(signString, comment: "")
        }
    }

    @IBOutlet weak var iconImageView: IconImageView!
    @IBOutlet weak var anniversaryNameLabel: UILabel!
    @IBOutlet weak var anniversaryDateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    /// AnniversaryVCから受け取るデータ
    var anniversaryId: String?
    var anniversaryName: String?
    var anniversaryDate: String?
    var remainingDays: String?
    var iconImage: UIImage?
    
    var category: String?
    
    var starSign: String?
    var chineseZodiacSign: String?
    
    
    // MARK: - ライフサイクル
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 大きいタイトルの表示設定
        navigationItem.largeTitleDisplayMode = .automatic
        
        guard let id = anniversaryId else { return }
        // IDをもとにDBから記念日データを取得する(非同期処理のコールバックで取得)
        // 非同期なので、クロージャ外の処理よりも後に反映されることになる
        AnniversaryDAO().getAnniversary(on: id) { anniversary in
            guard let date = (anniversary["date"] as? Timestamp)?.dateValue(),
                let category = anniversary["category"] as? String else { return }
            self.category = category
            self.starSign = self.getStarSign(date: date)
            self.chineseZodiacSign = self.getChineseZodiacSign(date: date)
            
            DispatchQueue.main.async {
                self.anniversaryDateLabel.text = DateTimeFormat().getYMDString(date: date)
                self.tableView.reloadData()
            }
        }
        // navigationbarのタイトル
        navigationItem.title = remainingDays
        // 前画面のセルから引き継いだ情報を表示する
        iconImageView.image = iconImage
        anniversaryNameLabel.text = anniversaryName
        anniversaryDateLabel.text = anniversaryDate
        
        let right = UIBarButtonItem(title: "非表示にする", style: .plain, target: self, action: #selector(toggleHidden))
        
        navigationItem.rightBarButtonItem = right
    }
    
    @objc private func toggleHidden() {
        print("非表示処理")
    }
    
    
    // MARK: - 汎用関数
    
    /// 星座を調べる
    ///
    /// - Parameter date: 星座を調べたい日付
    /// - Returns: 星座名
    private func getStarSign(date: Date) -> String {
        let sign: String
        
        let calendar = Calendar.current

        // 日付の「月」と「日」を取得
        let monthAndDayDate = calendar.dateComponents([.month, .day], from: date)

        switch (monthAndDayDate.month!, monthAndDayDate.day!) {
        case (3, 21...31), (4, 1...19):
            sign = StarSign.aries.localizedString()
        case (4, 20...31), (5, 1...20):
            sign = StarSign.taurus.localizedString()
        case (5, 21...31), (6, 1...21):
            sign = StarSign.gemini.localizedString()
        case (6, 22...31), (7, 1...22):
            sign = StarSign.cancer.localizedString()
        case (7, 23...31), (8, 1...22):
            sign = StarSign.leo.localizedString()
        case (8, 23...31), (9, 1...22):
            sign = StarSign.virgo.localizedString()
        case (9, 23...31), (10, 1...23):
            sign = StarSign.libra.localizedString()
        case (10, 24...31), (11, 1...22):
            sign = StarSign.scorpio.localizedString()
        case (11, 23...31), (12, 1...21):
            sign = StarSign.sagittarius.localizedString()
        case (12, 22...31), (1, 1...19):
            sign = StarSign.capricorn.localizedString()
        case (1, 20...31), (2, 1...18):
            sign = StarSign.aquarius.localizedString()
        case (2, 19...31), (3, 1...20):
            sign = StarSign.pisces.localizedString()
        default:
            sign = NSLocalizedString("unknown", comment: "")
        }
        return sign
    }
    
    /// 干支を調べる
    ///
    /// - Parameter date: 干支を調べたい日付
    /// - Returns: 十二支名
    private func getChineseZodiacSign(date: Date) -> String {
        let sign: String
        
        let calendar = Calendar.current
        
        // 日付の「年」を取得。1年なら「不明」
        guard let year = calendar.dateComponents([.year], from: date).year, year != 1 else {
            return NSLocalizedString("unknown", comment: "")
        }
        
        switch year % 12 {
        case 4:
            sign = ChineseZodiacSign.rat.localizedString()
        case 5:
            sign = ChineseZodiacSign.ox.localizedString()
        case 6:
            sign = ChineseZodiacSign.tiger.localizedString()
        case 7:
            sign = ChineseZodiacSign.rabbit.localizedString()
        case 8:
            sign = ChineseZodiacSign.dragon.localizedString()
        case 9:
            sign = ChineseZodiacSign.snake.localizedString()
        case 10:
            sign = ChineseZodiacSign.horse.localizedString()
        case 11:
            sign = ChineseZodiacSign.sheep.localizedString()
        case 0:
            sign = ChineseZodiacSign.monkey.localizedString()
        case 1:
            sign = ChineseZodiacSign.rooster.localizedString()
        case 2:
            sign = ChineseZodiacSign.dog.localizedString()
        case 3:
            sign = ChineseZodiacSign.pig.localizedString()
        default:
            sign = NSLocalizedString("unknown", comment: "")
        }
        return sign
    }

}


// MARK: - UITableViewDataSource
extension AnniversaryDetailVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // セルの数
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルの中身
        let cell = tableView.dequeueReusableCell(withIdentifier: "anniversaryDetailCell", for: indexPath)

        switch (category, indexPath.row) {
        case ("contactBirthday", 0):
            cell.textLabel?.text = "星座"
            cell.detailTextLabel?.text = starSign

        case ("contactBirthday", 1):
            cell.textLabel?.text = "干支"
            cell.detailTextLabel?.text = chineseZodiacSign
            
        default: break
        }
        return cell
    }
}


// MARK: - UITableViewDelegate

extension AnniversaryDetailVC: UITableViewDelegate {
    
}

//
//  AnniversaryDateRecordVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/19.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

class AnniversaryDateRecordVC: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet private weak var dateFormatControl: UISegmentedControl!
    @IBOutlet private weak var pickerView: UIPickerView!
    
    
    // MARK: - プロパティ

    let dateTimeFormat = DateTimeFormat()
    var anniversary: AnniversaryRecordModel!
    
    private var years: [Int]!
    private var months: [String]!
    private var days: [Int]!
    
    
    // MARK: - ライフサイクル

    override func viewDidLoad() {
        super.viewDidLoad()
        setPickerDefault()
    }
    
    /// 日付の年ありか年なしが変更された
    @IBAction private func didChangeDateFormat(_ sender: UISegmentedControl) {
        // ピッカーを更新してデフォルト設定を再度行う
        pickerView.reloadAllComponents()
        setPickerDefault()
    }
    
    /// ピッカーのデフォルト設定を行う
    private func setPickerDefault() {
        // 現在の年月日
        let nowYear = dateTimeFormat.getNowDateNumber(component: .year)
        let nowMonth = dateTimeFormat.getNowDateNumber(component: .month)
        let nowDay = dateTimeFormat.getNowDateNumber(component: .day)
        
        // ピッカーで選択できる範囲を設定
        years = [Int](2...nowYear+10)
        months = [NSLocalizedString("january", comment: ""),
                  NSLocalizedString("february", comment: ""),
                  NSLocalizedString("march", comment: ""),
                  NSLocalizedString("april", comment: ""),
                  NSLocalizedString("may", comment: ""),
                  NSLocalizedString("june", comment: ""),
                  NSLocalizedString("july", comment: ""),
                  NSLocalizedString("august", comment: ""),
                  NSLocalizedString("september", comment: ""),
                  NSLocalizedString("october", comment: ""),
                  NSLocalizedString("november", comment: ""),
                  NSLocalizedString("decenber", comment: "")]
        days = [Int](1...31)
        
        // デフォルト選択値の設定
        if dateFormatControl.selectedSegmentIndex == 0 {
            // 年有り（年は2始まりなので1多く引いている）
            pickerView.selectRow(nowYear - 1 - 1, inComponent: 0, animated: true)
            pickerView.selectRow(nowMonth - 1, inComponent: 1, animated: true)
            pickerView.selectRow(nowDay - 1, inComponent: 2, animated: true)
        } else {
            // 年なし
            pickerView.selectRow(nowMonth - 1, inComponent: 0, animated: true)
            pickerView.selectRow(nowYear - 1, inComponent: 1, animated: true)
        }
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard var anniversary = anniversary else { return }
        
        /// 登録用Anniversaryモデルに日付を登録
        // 選択されている行を取得（インデックスとのズレを加味）
        if dateFormatControl.selectedSegmentIndex == 0 {
            // 年有り
            let year = pickerView.selectedRow(inComponent: 0) + 2
            let month = pickerView.selectedRow(inComponent: 1) + 1
            let day = pickerView.selectedRow(inComponent: 2) + 1
            // 選択されている年月日をDate型に変換し記念日情報に追加
            anniversary.date = dateTimeFormat.toDateFormat(fromYear: year, month: month, day: day)

        } else {
            // 年なし
            let month = pickerView.selectedRow(inComponent: 0) + 1
            let day = pickerView.selectedRow(inComponent: 1) + 1
            // 選択されている年月日をDate型に変換し記念日情報に追加
            anniversary.date = dateTimeFormat.toDateFormat(fromYear: nil, month: month, day: day)
        }
        // 次のVCに記念日情報を渡す
        let nextVC = segue.destination as! AnniversaryRecordConfirmationVC
        nextVC.anniversary = anniversary
    }
}


// MARK: - UIPickerViewDataSource

extension AnniversaryDateRecordVC: UIPickerViewDataSource {
    
    /// 列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if dateFormatControl.selectedSegmentIndex == 0 {
            // 年有り
            return 3
        } else {
            // 年なし
            return 2
        }
    }
    
    /// 行の数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // 年ありか無しか・列のインデックス
        switch (dateFormatControl.selectedSegmentIndex, component) {
        // TODO: ローカライズ：英語圏だと月日年の順番
        case (0, 0): return years.count
        case (0, 1), (1, 0): return months.count
        case (0, 2), (1, 1): return days.count
        default: return 0
        }
    }
    
    /// 表示する内容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        // TODO: ローカライズ：英語圏だと月日年の順番
        // TODO: ローカライズ：日本語環境のみ"年", "日"を足す…
        case 0: return dateFormatControl.selectedSegmentIndex == 0
            ? years[row].description + "年" : months[row].description
        case 1: return dateFormatControl.selectedSegmentIndex == 0
            ? months[row].description : days[row].description + "日"
        case 2: return days[row].description + "日"
        default: return ""
        }
    }
}


// MARK: - UIPickerViewDelegate

extension AnniversaryDateRecordVC: UIPickerViewDelegate {
    
}

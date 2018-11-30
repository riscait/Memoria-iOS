//
//  AnniversaryDateRecordVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/19.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

class AnniversaryDateRecordVC: UIViewController {

    // セグメントコントロールの選択肢
    enum SelectedSegment: Int {
        case enabledYear
        case disabledYear
    }
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var dateFormatControl: UISegmentedControl!
    @IBOutlet private weak var pickerView: UIPickerView!
    
    
    // MARK: - プロパティ

    private let dateTimeFormat = DateTimeFormat()
    // 前画面から受け取ったAnniversaryデータ
    var anniversary: AnniversaryRecordModel!
    // 端末の言語
    private var language: DeviceLanguage?
    private var dateOrder: DeviceLanguage.DateOrder?
    
    private var years: [Int]!
    private var months: [String]!
    private var days: [Int]!
    
    private let enableYear = 0
    private let disableYear = 1
    private let first = 0
    private let second = 1
    private let third = 2

    var selectedSegment: SelectedSegment!

    // MARK: - ライフサイクル

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("date", comment: "")

        selectedSegment = SelectedSegment.init(rawValue: dateFormatControl.selectedSegmentIndex)!
        
        language = DeviceLanguage.getLanguage()
        dateOrder = language?.getDateOrder()
        setPickerDefault()
    }
    
    
    // MARK: - IBAction
    
    /// 日付の年ありか年なしが変更された
    @IBAction private func didChangeDateFormat(_ sender: UISegmentedControl) {
        selectedSegment = SelectedSegment.init(rawValue: dateFormatControl.selectedSegmentIndex)!
        // ピッカーを更新してデフォルト設定を再度行う
        pickerView.reloadAllComponents()
        setPickerDefault()
    }
    
    // MARK: - function
    
    /// ピッカーのデフォルト設定を行う
    private func setPickerDefault() {
        // 現在の年月日
        let nowYear = dateTimeFormat.getNowDateNumber(component: .year)
        let nowMonth = dateTimeFormat.getNowDateNumber(component: .month)
        let nowDay = dateTimeFormat.getNowDateNumber(component: .day)
        
        guard let selectedSegment = selectedSegment,
            let dateOrder = dateOrder else { return }
        
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
        // 年有りの場合（年は2始まりなので1多く引いている）
        switch (dateOrder, selectedSegment) {
        case (.ymd, .enabledYear):
            pickerView.selectRow(nowYear - 2, inComponent: first, animated: true)
            pickerView.selectRow(nowMonth - 1, inComponent: second, animated: true)
            pickerView.selectRow(nowDay - 1, inComponent: third, animated: true)

        case (.ymd, .disabledYear):
            pickerView.selectRow(nowMonth - 1, inComponent: first, animated: true)
            pickerView.selectRow(nowDay - 1, inComponent: second, animated: true)
            
        case (.mdy, .enabledYear):
            pickerView.selectRow(nowYear - 2, inComponent: third, animated: true)
            pickerView.selectRow(nowMonth - 1, inComponent: first, animated: true)
            pickerView.selectRow(nowDay - 1, inComponent: second, animated: true)

        case (.mdy, .disabledYear):
            pickerView.selectRow(nowMonth - 1, inComponent: first, animated: true)
            pickerView.selectRow(nowDay - 1, inComponent: second, animated: true)
        }
    }
    

    // MARK: - Navigation

    /// Segueでの遷移直前処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard var anniversary = anniversary,
            let selectedSegment = selectedSegment,
            let dateOrder = dateOrder else { return }

        // 登録用Anniversaryモデルに日付を登録する
        // 選択されている行を取得（インデックスとのズレを加味）
        switch (dateOrder, selectedSegment) {
        case (.ymd, .enabledYear):
            let year = pickerView.selectedRow(inComponent: first) + 2
            let month = pickerView.selectedRow(inComponent: second) + 1
            let day = pickerView.selectedRow(inComponent: third) + 1
            // 選択されている年月日をDate型に変換し記念日情報に追加
            anniversary.date = dateTimeFormat.toDateFormat(fromYear: year, month: month, day: day)

        case (.ymd, .disabledYear):
            let month = pickerView.selectedRow(inComponent: first) + 1
            let day = pickerView.selectedRow(inComponent: second) + 1
            // 選択されている年月日をDate型に変換し記念日情報に追加
            anniversary.date = dateTimeFormat.toDateFormat(fromYear: nil, month: month, day: day)

        case (.mdy, .enabledYear):
            let year = pickerView.selectedRow(inComponent: third) + 2
            let month = pickerView.selectedRow(inComponent: first) + 1
            let day = pickerView.selectedRow(inComponent: second) + 1
            // 選択されている年月日をDate型に変換し記念日情報に追加
            anniversary.date = dateTimeFormat.toDateFormat(fromYear: year, month: month, day: day)

        case (.mdy, .disabledYear):
            let month = pickerView.selectedRow(inComponent: first) + 1
            let day = pickerView.selectedRow(inComponent: second) + 1
            // 選択されている年月日をDate型に変換し記念日情報に追加
            anniversary.date = dateTimeFormat.toDateFormat(fromYear: nil, month: month, day: day)
        }

        // 次のVCに記念日情報を渡す
        let nextVC = segue.destination as! AnniversaryRecordConfirmationVC
        nextVC.anniversary = anniversary
    }
}


// MARK: - UIPickerViewDataSource & UIPickerViewDelegate

extension AnniversaryDateRecordVC: UIPickerViewDataSource, UIPickerViewDelegate {
    
    /// ピッカー列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if selectedSegment == .enabledYear {
            // 年有り
            print(selectedSegment)
            return 3
        } else {
            // 年なし
            print(selectedSegment)
           return 2
        }
    }
    
    /// ピッカー行の数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        guard let dateOrder = dateOrder,
            let selectedSegment = selectedSegment else { return 0 }

        // 年ありか無しか・列のインデックス
        switch (dateOrder, selectedSegment, component) {
        // 日付の順番, 年の有無, 左中右
        case (.ymd, .enabledYear, first),
             (.mdy, .enabledYear, third): return years.count
            
        case (.ymd, .enabledYear, second),
             (.ymd, .disabledYear, first),
             (.mdy, .enabledYear, first),
             (.mdy, .disabledYear, first): return months.count
            
        case (.ymd, .enabledYear, third),
             (.ymd, .disabledYear, second),
             (.mdy, .enabledYear, second),
             (.mdy, .disabledYear, second): return days.count
            
        default: return 0
        }
    }
    
    /// ピッカーに表示する内容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        print("表示内容を詰める")
        guard let dateOrder = dateOrder,
            let selectedSegment = selectedSegment else { return "" }

        switch (dateOrder, selectedSegment, component) {
        // 日付の順番, 年の有無, 左中右
        case (.ymd, .enabledYear, first),
             (.mdy, .enabledYear, third): print(years[row].description);return years[row].description + NSLocalizedString("japaneseOnlyYear", comment: "")
            
        case (.ymd, .enabledYear, second),
             (.ymd, .disabledYear, first),
             (.mdy, .enabledYear, first),
             (.mdy, .disabledYear, first): print(months[row].description);return months[row].description
            
        case (.ymd, .enabledYear, third),
             (.ymd, .disabledYear, second),
             (.mdy, .enabledYear, second),
             (.mdy, .disabledYear, second): print(days[row].description);return days[row].description + NSLocalizedString("japaneseOnlyDay", comment: "")

        default: return ""
        }
    }
}

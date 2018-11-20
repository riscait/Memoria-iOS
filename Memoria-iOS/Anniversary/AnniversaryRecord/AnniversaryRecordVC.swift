//
//  AnniversaryRecordVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/19.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

class AnniversaryRecordVC: UIViewController {

    @IBOutlet weak var familyName: UITextField!
    @IBOutlet weak var givenName: UITextField!
    @IBOutlet weak var anniversaryTitle: UITextField!
    
    enum Segue: String {
        case birthday = "recordBirthdaySegue"
        case others = "recordAnyAnniversarySegue"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let id = segue.identifier else { return }
        
        let anniversary: AnniversaryRecord
        
        switch id {
        case Segue.birthday.rawValue:
            anniversary = AnniversaryRecord(givenName: givenName.text ?? "", familyName: familyName.text ?? "")

        case Segue.others.rawValue:
            anniversary = AnniversaryRecord(title: anniversaryTitle.text ?? "")

        default: break
        }

        let nextVC = segue.destination as! AnniversaryDateRecordVC
//        nextVC.anniversary = anniversary
    }
}

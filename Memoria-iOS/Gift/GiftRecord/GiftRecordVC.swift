//
//  GiftRecordVC.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/16.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

class GiftRecordVC: UIViewController {

    @IBOutlet weak var recordButton: UIBarButtonItem!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ContainerViewを特定
        for child in children {
            if let child = child as? GiftRecordTableVC {
                let tableVC = child
                // GiftRecordTableVCのデリゲートをこのクラスに移譲する
                tableVC.giftRecordTableVCDelegate = self
                break
            }
        }
    }
    
    @IBAction func didTapCancelButton(_ sender: UIBarButtonItem) {
        DialogBox.showDestructiveAlert(on: self, message: "realy".localized, destructiveTitle: "discard") {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapRecordButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
//
extension GiftRecordVC: GiftRecordTableVCDelegate {
    func recordingStandby(_ enabled: Bool) {
        recordButton.isEnabled = enabled
    }
}

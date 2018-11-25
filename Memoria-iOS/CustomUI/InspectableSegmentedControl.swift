//
//  InspectableSegmentedControl.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/11/25.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

@IBDesignable class InspectableSegmentedControl: UISegmentedControl {

    @IBInspectable var localizedStringKey1: String = "" {
        didSet {
            guard !localizedStringKey1.isEmpty else { return }
            setTitle(NSLocalizedString(localizedStringKey1, comment: ""), forSegmentAt: 0)
        }
    }
    @IBInspectable var localizedStringKey2: String = "" {
        didSet {
            guard !localizedStringKey2.isEmpty else { return }
            setTitle(NSLocalizedString(localizedStringKey2, comment: ""), forSegmentAt: 1)
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

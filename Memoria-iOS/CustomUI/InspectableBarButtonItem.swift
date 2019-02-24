//
//  InspectableBarButtonItem.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/01/06.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import UIKit

@IBDesignable class InspectableBarButtonItem: UIBarButtonItem {

    @IBInspectable var localizedStringKey: String = "" {
        didSet {
            guard !localizedStringKey.isEmpty else { return }
            
            title = NSLocalizedString(localizedStringKey, comment: "")
        }
    }

}

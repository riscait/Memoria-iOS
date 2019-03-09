//
//  InspectableNavItem.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/13.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

@IBDesignable class InspectableNavItem: UINavigationItem {

    @IBInspectable var localizedStringKey: String = "" {
        didSet {
            guard !localizedStringKey.isEmpty else { return }
            
            title = NSLocalizedString(localizedStringKey, comment: "")
        }
    }
}

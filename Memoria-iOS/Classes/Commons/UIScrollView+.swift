//
//  UIScrollView+.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/05/03.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import UIKit

extension UIScrollView {
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesBegan(touches, with: event)
    }
}

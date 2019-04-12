//
//  EventTrackable.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2019/04/12.
//  Copyright © 2019 nerco studio. All rights reserved.
//

import Foundation
import Repro

protocol EventTrackable {}

extension EventTrackable where Self: UIViewController {
    
    func trackScreen() {
        let className = String(describing: type(of: self))
        Repro.track(className, properties: nil)
        Log.info("\(className) was displayed")
    }
    
}

//
//  GiftRecordSelectProtocol.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/26.
//  Copyright © 2018 nerco studio. All rights reserved.
//
import UIKit
import Foundation

protocol GiftRecordSelectProtocol: AnyObject {
    
    var displayData: [String] { get set }
    
    func searchDB()
    func popVC()
}

extension GiftRecordSelectProtocol {
    var searchController: UISearchController {
        return UISearchController(searchResultsController: nil)
    }
}

//
//  InspectableTableViewCell.swift
//  Memoria-iOS
//
//  Created by 村松龍之介 on 2018/12/24.
//  Copyright © 2018 nerco studio. All rights reserved.
//

import UIKit

@IBDesignable class InspectableTableViewCell: UITableViewCell {

    @IBInspectable var accessoryImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateView()
    }
    
    func updateView() {
        if let accessoryImage = accessoryImage {
            self.accessoryType = .detailDisclosureButton
            self.accessoryView = UIImageView(image: accessoryImage)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

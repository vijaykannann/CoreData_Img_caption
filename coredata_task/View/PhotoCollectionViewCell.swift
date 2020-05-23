//
//  PhotoCollectionViewCell.swift
//  coredata_task
//
//  Created by VJ's iMAC on 23/05/20.
//  Copyright © 2020 Deuglo. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var contentHolder: UIView!
    @IBOutlet weak var photoImgView: UIImageView!
    
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

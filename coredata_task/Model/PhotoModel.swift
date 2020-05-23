//
//  PhotoModel.swift
//  coredata_task
//
//  Created by VJ's iMAC on 23/05/20.
//  Copyright © 2020 Deuglo. All rights reserved.
//

import UIKit
import Photos

class PhotoModel {
    var id: Int!
    var asset: PHAsset!
    var comment: String = ""
    var caption: String = ""
    var image: UIImage!
    
    init() {
    }
}

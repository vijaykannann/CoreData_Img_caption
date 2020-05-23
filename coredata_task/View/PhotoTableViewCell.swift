//
//  PhotoTableViewCell.swift
//  coredata_task
//
//  Created by VJ's iMAC on 23/05/20.
//  Copyright © 2020 Deuglo. All rights reserved.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {

    @IBOutlet weak var imageVView: UIImageView!
    @IBOutlet weak var captionTextField: TextFieldHelper!
    
    @IBOutlet weak var commentTextField: TextFieldHelper!
    
    class var identifier: String {
        return String(describing: self)
    }
    
   internal var aspectConstraint : NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                imageVView.removeConstraint(oldValue!)
            }
            if aspectConstraint != nil {
                imageVView.addConstraint(aspectConstraint!)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        aspectConstraint = nil
    }
    
    func setCustomImage(image : UIImage) {
        
        let aspect = image.size.width / image.size.height
        
        let constraint = NSLayoutConstraint(item: imageVView!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: imageVView, attribute: NSLayoutConstraint.Attribute.height, multiplier: aspect, constant: 0.0)
        constraint.priority = UILayoutPriority(rawValue: 999)
        aspectConstraint = constraint
        imageVView.image = image
    }
    
}

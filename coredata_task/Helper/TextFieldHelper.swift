//
//  TextFieldHelper.swift
//  coredata_task
//
//  Created by VJ's iMAC on 23/05/20.
//  Copyright © 2020 Deuglo. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class TextFieldHelper: UITextField {
    var textChanged: (String) ->() = { _ in }
    
    public func bind(callback :@escaping (String) -> ()) {
        self.textChanged = callback
        self.addTarget(self, action: #selector(textFieldDidChange), for: .allEvents)
    }

    @IBAction func textFieldDidChange(_ textField : UITextField) {
        self.textChanged(textField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
    }
}

//
//  PBPickerController.swift
//  
//
//  Created by Noah Little on 12/3/2022.
//

import UIKit
import Preferences

class PBPickerController: PSListItemsController {
    override func tableViewStyle() -> UITableView.Style {
        if #available(iOS 13.0, *) {
            return .insetGrouped
        } else {
            return .grouped
        }
    }
}

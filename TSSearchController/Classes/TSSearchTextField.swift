//
//  TSSearchTextField.swift
//  LTSSearchController
//
//  Created by 李棠松 on 2018/1/31.
//  Copyright © 2018年 李棠松. All rights reserved.
//

import UIKit

class TSSearchTextField: UITextField {
    var canTouch: Bool = true
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let result = super.point(inside: point, with: event)
        if canTouch {
            return result
        }
        return false
    }

}

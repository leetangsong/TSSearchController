//
//  UIView+TSSearch.swift
//  LTSSearchController
//
//  Created by 李棠松 on 2018/1/31.
//  Copyright © 2018年 李棠松. All rights reserved.
//

import UIKit

extension UIView {
    
    var ts_viewController: UIViewController?{
        var next = self.next
        repeat {
            if next?.isKind(of: UIViewController.self) == true{
                return next as? UIViewController
            }
            next = next?.next
        } while (next != nil)
        return nil;
    }
    var ts_x : CGFloat {
        get{
            return  self.frame.origin.x
        }
        set{
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    
    var ts_y : CGFloat {
        get{
            return  self.frame.origin.y
        }
        set{
            
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    
    var ts_width : CGFloat {
        get{
            return  self.frame.size.width
        }
        set{
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }
    
    var ts_height : CGFloat {
        get{
            
            return  self.frame.size.height
        }
        set{
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }
    
}

extension UIImage{
    static func image(name: String)->UIImage?{
       return  UIImage.init(named: "TSSearchController.bundle/\(name)", in: Bundle.init(for: NSClassFromString("TSSearchController.TSSearchController")!), compatibleWith: nil)
    }
}

//
//  ViewController.swift
//  TSSearchController
//
//  Created by leetangsong on 02/06/2018.
//  Copyright (c) 2018 leetangsong. All rights reserved.
//

import UIKit
import TSSearchController
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(TSSearchController.init(searchResultsController: nil).searchBar)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


//
//  ViewController.swift
//  Project 18 Debugging
//
//  Created by Gerjan te Velde on 25/02/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var testBool = true
        
        print("Beautiful", 1, "and", 2, "perfect", 3, "test", 4, separator: " - ", terminator: " - end")
        assert(testBool, "Error: testBool is false")
        
        for i in 1 ... 100 {
            print("Got number \(i)")
        }
    }


}


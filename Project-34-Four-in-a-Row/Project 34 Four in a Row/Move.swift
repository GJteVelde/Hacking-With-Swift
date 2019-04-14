//
//  Move.swift
//  Project 34 Four in a Row
//
//  Created by Gerjan te Velde on 01/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit
import GameplayKit

class Move: NSObject, GKGameModelUpdate {

    var value: Int = 0
    var column: Int
    
    init(column: Int) {
        self.column = column
    }
}

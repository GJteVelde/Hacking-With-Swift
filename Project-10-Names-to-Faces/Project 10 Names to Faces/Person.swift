//
//  Person.swift
//  Project 10 Names to Faces
//
//  Created by Gerjan te Velde on 03/02/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class Person: NSObject, Codable {
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}

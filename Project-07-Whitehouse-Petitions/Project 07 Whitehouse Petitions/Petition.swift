//
//  Petition.swift
//  Project 07 Whitehouse Petitions
//
//  Created by Gerjan te Velde on 30/01/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import Foundation

struct Petition: Codable {
    var title: String
    var body: String
    var signatureCount: Int
}

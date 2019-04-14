//
//  Whistle.swift
//  Project 33 What's that Whistle
//
//  Created by Gerjan te Velde on 04/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit
import CloudKit

class Whistle: NSObject {

    var recordID: CKRecord.ID!
    var genre: String!
    var comments: String!
    var audio: URL!
}

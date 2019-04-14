//
//  Commit+CoreDataClass.swift
//  Project 38 GitHub Commits
//
//  Created by Gerjan te Velde on 05/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Commit)
public class Commit: NSManagedObject {
    override public init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        print("Init called!")
    }
}

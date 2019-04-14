//
//  Commit+CoreDataProperties.swift
//  Project 38 GitHub Commits
//
//  Created by Gerjan te Velde on 08/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//
//

import Foundation
import CoreData


extension Commit {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Commit> {
        return NSFetchRequest<Commit>(entityName: "Commit")
    }

    @NSManaged public var date: Date
    @NSManaged public var message: String
    @NSManaged public var sha: String
    @NSManaged public var url: String
    @NSManaged public var author: Author

}

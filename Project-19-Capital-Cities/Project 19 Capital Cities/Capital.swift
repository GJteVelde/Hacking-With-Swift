//
//  Capital.swift
//  Project 19 Capital Cities
//
//  Created by Gerjan te Velde on 25/02/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit
import MapKit

class Capital: NSObject, MKAnnotation {

    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    var isFavorite: Bool
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String, isFavorite: Bool) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
        self.isFavorite = isFavorite
    }
}

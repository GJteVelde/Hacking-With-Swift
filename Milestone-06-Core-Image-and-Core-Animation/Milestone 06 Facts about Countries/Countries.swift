//
//  Countries.swift
//  Milestone 06 Facts about Countries
//
//  Created by Gerjan te Velde on 23/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import Foundation

struct Root: Decodable {
    let response: [Country]
    
    enum CodingKeys: String, CodingKey {
        case response = "Response"
    }
}

struct Country: Decodable {
    let name: String
    let region: String
    let currencyName: String
    let flagPng: String
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case region = "Region"
        case currencyName = "CurrencyName"
        case flagPng = "FlagPng"
    }
}

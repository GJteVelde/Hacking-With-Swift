//
//  PlayData.swift
//  Project 39 Unit testing with XCTest
//
//  Created by Gerjan te Velde on 10/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import Foundation

class PlayData {
    var allWords = [String]()
    var wordCounts: NSCountedSet!
    private(set) var filteredWords = [String]()
    
    init() {
        if let path = Bundle.main.path(forResource: "plays", ofType: "txt") {
            if let plays = try? String(contentsOfFile: path) {
                allWords = plays.components(separatedBy: CharacterSet.alphanumerics.inverted)
                allWords = allWords.filter { $0 != "" }
                
                wordCounts = NSCountedSet(array: allWords)
                
//                let sorted = wordCounts.allObjects.sorted { (first, second) -> Bool in
//                    wordCounts.count(for: first) > wordCounts.count(for: second)
//                }
                
                let sorted = wordCounts.allObjects.sorted { wordCounts.count(for: $0) > wordCounts.count(for: $1) }
                
                allWords = sorted as! [String]
                applyUserFilter("swift")
            }
        }
    }
    
    func applyUserFilter(_ input: String) {
        if let userNumber = Int(input) {
//            filteredWords = allWords.filter({ (word) -> Bool in
//                self.wordCounts.count(for: word) >= userNumber
//            })
            
            applyFilter { self.wordCounts.count(for: $0) >= userNumber }
        } else {
//            filteredWords = allWords.filter({ (word) -> Bool in
//                word.range(of: input, options: .caseInsensitive) != nil
//            })
            
            applyFilter { $0.range(of: input, options: .caseInsensitive) != nil }
        }
    }
    
    func applyFilter(_ filter: (String) -> Bool) {
        filteredWords = allWords.filter(filter)
    }
}

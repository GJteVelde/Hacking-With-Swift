//
//  Note.swift
//  Milestone 07 Notes App
//
//  Created by Gerjan te Velde on 25/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import Foundation

class Note: NSObject, NSCoding {
    
    var text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(text, forKey: "text")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let text = aDecoder.decodeObject(forKey: "text") as? String else { return nil }
        self.init(text)
    }
    
    private static let maxTitleLength = 50
    
    var title: String {
        get {
            if let returnIndex = text.firstIndex(of: "\n") {
                let titleIndex = String(text.prefix(upTo: returnIndex))
                
                if titleIndex.count <= Note.maxTitleLength {
                    return titleIndex
                }
            } else if text.count <= Note.maxTitleLength {
                return text
            }
            
            return String(text.prefix(Note.maxTitleLength) + "...")
        }
    }
    
    var textPreview: String {
        get {
            if title.hasSuffix("...") {
                var tempText = text.dropFirst(Note.maxTitleLength)
                
                if let index = tempText.firstIndex(of: " ") {
                    tempText = tempText[index...]
                    tempText.removeFirst(1)
                }
                
                return String(tempText)
            } else {
                return String(text.dropFirst(title.count + 1))
            }
        }
    }
}

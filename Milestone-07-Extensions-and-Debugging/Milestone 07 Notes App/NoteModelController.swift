//
//  NoteModelController.swift
//  Milestone 07 Notes App
//
//  Created by Gerjan te Velde on 25/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import Foundation

class NoteModelController {
    var notes = [Note]()
    
    init() {
        self.loadNotes()
    }
    
    private func notesURL() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("notes")
    }
    
    func loadNotes() {
        do {
            let data = try Data(contentsOf: notesURL())
            if let loadedNotes = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Note] {
                notes = loadedNotes
            }
        } catch {
            print("Couldn't load data.")
        }
    }
    
    func saveNotes() {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: notes, requiringSecureCoding: false)
            try data.write(to: notesURL())
        } catch {
            print("Couldn't save data.")
        }
    }
}

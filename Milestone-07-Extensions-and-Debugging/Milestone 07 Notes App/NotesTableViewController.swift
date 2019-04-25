//
//  NotesTableViewController.swift
//  Milestone 07 Notes App
//
//  Created by Gerjan te Velde on 25/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class NotesTableViewController: UITableViewController {

    //MARK: - Objects and Properties
    var noteModelController: NoteModelController!
    var notes = [Note]()
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        title = "Notes"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: - Table View Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteModelController.notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotesCell", for: indexPath)
        
        let note = noteModelController.notes[indexPath.row]
        cell.textLabel?.text = note.title
        cell.detailTextLabel?.text = note.textPreview
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        noteModelController.notes.remove(at: indexPath.row)
        noteModelController.saveNotes()
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    //MARK: - Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let noteDetailViewController = segue.destination as? NoteDetailViewController, let index = tableView.indexPathForSelectedRow?.row else { return }
        
        if segue.identifier == "EditNoteDetailIdentifier" {
            noteDetailViewController.note = noteModelController.notes[index]
        }
     }
    
    @IBAction func saveUnwindSegue(_ unwindSegue: UIStoryboardSegue) {
        guard let noteDetailViewController = unwindSegue.source as? NoteDetailViewController else { return }
        
        if let note = noteDetailViewController.note {
            if note.text == "" {
                note.text = "New note"
            }
            
            if let indexPath = tableView.indexPathForSelectedRow {
                noteModelController.notes[indexPath.row] = note
                tableView.reloadRows(at: [indexPath], with: .automatic)
            } else {
                noteModelController.notes.append(note)
                tableView.insertRows(at: [IndexPath(row: noteModelController.notes.count - 1, section: 0)], with: .automatic)
            }
            
            noteModelController.saveNotes()
        }
    }
    
    @IBAction func deleteUnwindSegue(_ unwindSegue: UIStoryboardSegue) {
        if let indexPath = tableView.indexPathForSelectedRow {
            noteModelController.notes.remove(at: indexPath.row)
            noteModelController.saveNotes()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}


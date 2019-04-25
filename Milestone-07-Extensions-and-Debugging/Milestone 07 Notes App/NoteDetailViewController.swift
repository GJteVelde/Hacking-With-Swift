//
//  NoteDetailViewController.swift
//  Milestone 07 Notes App
//
//  Created by Gerjan te Velde on 25/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class NoteDetailViewController: UIViewController, UITextViewDelegate {

    //MARK: - Objects and Properties
    var note: Note?
    var willDeleteNote = false
    
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var noteTextView: UITextView!
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        noteTextView.delegate = self
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if note != nil {
            noteTextView.text = note!.text
            doneBarButton.isEnabled = false
        } else {
            noteTextView.text = ""
            noteTextView.becomeFirstResponder()
            doneBarButton.isEnabled = false
        }
        
        navigationItem.rightBarButtonItem!.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !willDeleteNote {
            performSegue(withIdentifier: "SaveUnwindSegue", sender: self)
        }
    }
    
    //MARK: - TextField Delegate Methods
    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text {
            navigationItem.rightBarButtonItem!.isEnabled = !text.isEmpty
            doneBarButton.isEnabled = !text.isEmpty
        }
    }
    
    //MARK: - Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let noteText = noteTextView.text {
            note = Note(noteText)
        }
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            noteTextView.contentInset = UIEdgeInsets.zero
        } else {
            noteTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        noteTextView.scrollIndicatorInsets = noteTextView.contentInset
        
        let selectedRange = noteTextView.selectedRange
        noteTextView.scrollRangeToVisible(selectedRange)
    }
    
    //MARK: - Actions
    @IBAction func toolbarBarButtonItemTouched(_ sender: UIBarButtonItem) {
        if sender.tag == 1 {
            willDeleteNote = true
            performSegue(withIdentifier: "DeleteUnwindSegue", sender: self)
        } else if sender.tag == 2 {
            guard note != nil else { return }
            
            let activityViewController = UIActivityViewController(activityItems: [note!.text], applicationActivities: nil)
            present(activityViewController, animated: true)
        }
    }
    
    @IBAction func doneBarButtonTouched(_ sender: UIBarButtonItem) {
        noteTextView.resignFirstResponder()
        doneBarButton.isEnabled = false
    }
}

//
//  InterfaceController.swift
//  Project 37 Psychic Tester WatchKit Extension
//
//  Created by Gerjan te Velde on 11/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    //MARK: - Objects and Properties
    @IBOutlet weak var welcomeText: WKInterfaceLabel!
    @IBOutlet weak var hideButton: WKInterfaceButton!
    @IBOutlet weak var winningModeButton: WKInterfaceButton!
    
    var winningMode = false
    
    //MARK: - View Controller Life Cycle
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        winningModeButton.setAlpha(0.05)
        winningModeButton.setRelativeHeight(1, withAdjustment: 0)
        winningModeButton.setRelativeWidth(1, withAdjustment: 0)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    //MARK: - Actions
    @IBAction func hideWelcomeText() {
        welcomeText.setHidden(true)
        hideButton.setHidden(true)
        winningModeButton.setHidden(false)
    }
    
    @IBAction func winningModeButtonTapped() {
        if (WCSession.default.isReachable) {
            winningMode = !winningMode
            
            let message = ["winningMode": winningMode]
            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: nil)
            
            if winningMode {
                winningModeButton.setTitle("Deactivate Winning Mode")
            } else {
                winningModeButton.setTitle("Activate Winning Mode")
            }
            
            print("winningModeButtonTapped(): Send message to iPhone app; WinningMode: \(winningMode)")
        } else {
            print("winningModeButtonTapped(): WCSession is not reachable.")
        }
    }
    
    //MARK: - WatchConnectivity (Delegate) Methods
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        WKInterfaceDevice().play(.click)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

    }
}

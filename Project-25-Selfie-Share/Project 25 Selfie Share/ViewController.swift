//
//  ViewController.swift
//  Project 25 Selfie Share
//
//  Created by Gerjan te Velde on 09/03/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate {

    //MARK: - Objects and Properties
    var images = [UIImage]()
    
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let connectBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showConnectionPrompt))
        let connectionsBarButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showConnections))
        
        let cameraBarButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(importPicture))
        let textBarButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeText))
        
        navigationItem.leftBarButtonItems = [connectBarButton, connectionsBarButton]
        navigationItem.rightBarButtonItems = [textBarButton, cameraBarButton]
        
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
    }

    //MARK: - Collection View Datasource Methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath)
        
        if let imageView = cell.viewWithTag(1000) as? UIImageView {
            imageView.image = images[indexPath.item]
        }
        
        return cell
    }
    
    //MARK: - Methods
    @objc func showConnectionPrompt() {
        let alertController = UIAlertController(title: "Connect", message: nil, preferredStyle: .actionSheet)
        
        alertController.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
        alertController.addAction(UIAlertAction(title: "Host a session", style: .default, handler: startHosting))
        alertController.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    @objc func showConnections() {
        performSegue(withIdentifier: "ConnectionsSegue", sender: self)
    }
    
    func startHosting(action: UIAlertAction) {
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "hws-project25", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant.start()
    }
    
    func joinSession(action: UIAlertAction) {
        let mcBrowser = MCBrowserViewController(serviceType: "hws-project25", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }
    
    @objc func importPicture() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera not available")
            return
        }
            
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    @objc func composeText(action: UIAlertAction! = nil) {
        let alertController = UIAlertController(title: "Message", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter text here..."
        }
        
        alertController.addAction(UIAlertAction(title: "Send", style: .default, handler: { [unowned self, alertController] (action: UIAlertAction) in
            if let textField = alertController.textFields?.first, let text = textField.text {
                let message = ["sender": UIDevice.current.name, "message": text]
                
                if self.mcSession.connectedPeers.count > 0 {
                    if let messageData: NSData = try? NSKeyedArchiver.archivedData(withRootObject: message, requiringSecureCoding: true) as NSData {
                    //if let stringData = text.data(using: String.Encoding.utf8) {
                        do {
                            try self.mcSession.send(messageData as Data, toPeers: self.mcSession.connectedPeers, with: .reliable)
                        } catch {
                            let alertController = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alertController, animated: true)
                        }
                    }
                }
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    //MARK: - Delegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        images.insert(image, at: 0)
        collectionView?.reloadData()
        
        if mcSession.connectedPeers.count > 0 {
            if let imageData = image.pngData() {
                do {
                    try mcSession.send(imageData, toPeers: mcSession.connectedPeers, with: .reliable)
                } catch {
                    let alertController = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default))
                    present(alertController, animated: true)
                }
            }
        }
        
        dismiss(animated: true)
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("Connected: \(peerID.displayName)")
        case .connecting:
            print("Connecting: \(peerID.displayName)")
        case .notConnected:
            print("Not Connected: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let image = UIImage(data: data) {
            DispatchQueue.main.async { [unowned self] in
                self.images.insert(image, at: 0)
                self.collectionView?.reloadData()
            }
        } else if let message = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String: String] {
        //} else if let text = String(data: data, encoding: String.Encoding.utf8) {
            if let sender = message?["sender"], let text = message?["message"] {
                DispatchQueue.main.async { [unowned self] in
                    let alertController = UIAlertController(title: "Message from \(sender)", message: text, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default))
                    alertController.addAction(UIAlertAction(title: "Reply", style: .default, handler: self.composeText))
                    self.present(alertController, animated: true)
                }
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
    
    //Mark: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ConnectionsSegue" {
            let destination = segue.destination as! ConnectionsTableViewController
            
            var connectedDevices = [String]()
            for peer in mcSession.connectedPeers {
                connectedDevices.append(peer.displayName)
            }
            destination.connectedDevices = connectedDevices
        }
    }

}


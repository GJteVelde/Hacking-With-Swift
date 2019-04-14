//
//  ViewController.swift
//  Project 13 Instafilter
//
//  Created by Gerjan te Velde on 09/02/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //MARK: - Objects and properties
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var intensity: UISlider!
    @IBOutlet var radius: UISlider!
    @IBOutlet var scale: UISlider!
    @IBOutlet var changeFilterButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    
    var currentImage: UIImage!
    var context: CIContext!
    var currentFilter: CIFilter! {
        didSet {
            changeFilterButton.setTitle(currentFilter.name, for: .normal)
        }
    }
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Instafilter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        
        saveButton.isEnabled = false
        changeFilterButton.isEnabled = false
        intensity.isEnabled = false
        radius.isEnabled = false
        scale.isEnabled = false
        
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
    }
    
    //MARK: - Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        
        currentImage = image
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
        
        changeFilterButton.isEnabled = true
        saveButton.isEnabled = true
    }
    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            intensity.isEnabled = true
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        } else {
            intensity.value = 0.5
            intensity.isEnabled = false
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            radius.isEnabled = true
            currentFilter.setValue(radius.value * 200, forKey: kCIInputRadiusKey)
        } else {
            radius.value = 0.5
            radius.isEnabled = false
        }
        if inputKeys.contains(kCIInputScaleKey) {
            scale.isEnabled = true
            currentFilter.setValue(scale.value * 10, forKey: kCIInputScaleKey)
        } else {
            scale.value = 0.5
            scale.isEnabled = false
        }
        if inputKeys.contains(kCIInputCenterKey) {
            currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
        }
        
        
        if let cgimage = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent) {
            let processedImage = UIImage(cgImage: cgimage)
            imageView.image = processedImage
        }
    }
    
    func setFilter(action: UIAlertAction) {
        guard currentImage != nil else { return }
        
        currentFilter = CIFilter(name: action.title!)
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let alertController = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            present(alertController, animated: true)
        } else {
            let alertController = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            present(alertController, animated: true)
        }
    }
    
    //MARK: - Actions
    @IBAction func changeFilterTouchUpInside(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        alertController.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
        alertController.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        alertController.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        alertController.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        alertController.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        alertController.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    @IBAction func saveTouchUpInside(_ sender: UIButton) {
        
        UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func intensityValueChanged(_ sender: UISlider) {
        applyProcessing()
    }
}


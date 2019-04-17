//
//  ViewController.swift
//  Project 27 Core Graphics
//
//  Created by Gerjan te Velde on 17/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //MARK: - Properties & Objects
    @IBOutlet weak var imageView: UIImageView!
    
    var currentDrawType = 0
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawRectangle()
    }
    
    //MARK: - Methods
    func drawRectangle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { (context) in
            let rectangle = CGRect(x: 5, y: 5, width: 502, height: 502)
            
            context.cgContext.setFillColor(UIColor.red.cgColor)
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.setLineWidth(10)
            
            context.cgContext.addRect(rectangle)
            context.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = image
    }
    
    func drawCircle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { (context) in
            let rectangle = CGRect(x: 5, y: 5, width: 502, height: 502)
            
            context.cgContext.setFillColor(UIColor.red.cgColor)
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.setLineWidth(10)
            
            context.cgContext.addEllipse(in: rectangle)
            context.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = image
    }
    
    func drawCheckerboard() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { (context) in
            for row in 0 ..< 8 {
                for col in 0 ..< 8 {
                    if (row + col) % 2 == 0 {
                        context.cgContext.setFillColor(UIColor.black.cgColor)
                        context.cgContext.fill(CGRect(x: col * 64, y: row * 64, width: 64, height: 64))
                    } else {
                        context.cgContext.setFillColor(UIColor.red.cgColor)
                        context.cgContext.fillEllipse(in: CGRect(x: col * 64, y: row * 64, width: 64, height: 64))
                    }
                }
            }
        }
        
        imageView.image = image
    }
    
    func drawRotatedSquares() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { (context) in
            context.cgContext.translateBy(x: 256, y: 256)
            
            let rotations = 16
            let amount = Double.pi / Double(rotations)
            
            for _ in 0 ..< rotations {
                context.cgContext.rotate(by: CGFloat(amount))
                context.cgContext.addRect(CGRect(x: -128, y: -128, width: 256, height: 256))
            }
            
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.strokePath()
        }
        
        imageView.image = image
    }
    
    func drawLines() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { (context) in
            context.cgContext.translateBy(x: 256, y: 256)
            
            var first = true
            var length: CGFloat = 256
            
            for _ in 0 ..< 256 {
                context.cgContext.rotate(by: CGFloat.pi / 2)
                
                if first {
                    context.cgContext.move(to: CGPoint(x: length, y: 50))
                    first = false
                } else {
                    context.cgContext.addLine(to: CGPoint(x: length, y: 50))
                }
                
                length *= 0.99
            }
            
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.strokePath()
        }
        
        imageView.image = image
    }
    
    func drawImagesAndText() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let image = renderer.image { (context) in
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 36)!, NSAttributedString.Key.paragraphStyle: paragraphStyle]
            
            let string = "The best-laid schemes o'\nmice an' men gang aft agley"
            string.draw(with: CGRect(x: 32, y: 32, width: 448, height: 448), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            
            let mouse = UIImage(named: "mouse")
            mouse?.draw(at: CGPoint(x: 300, y: 150))
        }
        
        imageView.image = image
    }

    //MARK: - Actions
    @IBAction func redrawTouchUpInside(_ sender: UIButton) {
        currentDrawType += 1
        
        if currentDrawType > 5 {
            currentDrawType = 0
        }
        
        switch currentDrawType {
        case 0:
            drawRectangle()
        case 1:
            drawCircle()
        case 2:
            drawCheckerboard()
        case 3:
            drawRotatedSquares()
        case 4:
            drawLines()
        case 5:
            drawImagesAndText()
        default:
            break
        }
    }
    
}


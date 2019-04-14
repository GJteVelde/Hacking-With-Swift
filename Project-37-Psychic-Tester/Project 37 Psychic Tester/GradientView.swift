//
//  GradientView.swift
//  Project 37 Psychic Tester
//
//  Created by Gerjan te Velde on 12/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import UIKit

@IBDesignable class GradientView: UIView {
    @IBInspectable var topColor: UIColor = UIColor.white
    @IBInspectable var bottomColor: UIColor = UIColor.black
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
         (layer as! CAGradientLayer).colors = [topColor.cgColor, bottomColor.cgColor]
    }
}

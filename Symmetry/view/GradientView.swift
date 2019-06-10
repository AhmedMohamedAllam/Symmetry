//
//  GradientView.swift
//  Symmetry
//
//  Created by Ahmed Allam on 5/23/19.
//  Copyright © 2019 Ahmed Allam. All rights reserved.
//

import UIKit

extension UIView {
    func setGradientBackground(topToBottom: Bool) {
        let colorTop =  UIColor.black.withAlphaComponent(0).cgColor
        let colorBottom = UIColor.black.withAlphaComponent(1).cgColor
        
        let colors = topToBottom ? [colorTop, colorBottom] : [colorBottom, colorTop]
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
//        gradientLayer.locations = [0.0, 0.0]
        gradientLayer.frame = bounds
        
        layer.insertSublayer(gradientLayer, at:0)
    }
}


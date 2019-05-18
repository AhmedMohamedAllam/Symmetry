//
//  NSUserDefaults+UIColor.swift
//  Symmetry
//
//  Created by Ahmed Allam on 3/31/19.
//  Copyright © 2019 Ahmed Allam. All rights reserved.
//

import UIKit

extension UserDefaults {
    
    func color(forKey key: String) -> UIColor? {
        var color: UIColor?
        if let colorData = data(forKey: key) {
            color = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor
        }
        return color
    }
    
    func set(_ value: UIColor?, forKey key: String) {
        var colorData: Data?
        if let color = value {
            colorData = NSKeyedArchiver.archivedData(withRootObject: color)
        }
        set(colorData, forKey: key)
    }
    
}

extension UIImage{
    func squareImage() -> UIImage{
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        let width = self.size.width
        let height = self.size.height
        let ratio = screenWidth/width
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: screenWidth, height: screenWidth), false, 0.0)
        let ctx = UIGraphicsGetCurrentContext()!
        let y = ((screenWidth - screenHeight) * 0.5)
        ctx.translateBy(x: 0,y: y)
        self.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: screenWidth, height: height * ratio)))
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

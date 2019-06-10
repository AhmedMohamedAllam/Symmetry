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

        let originalImageWidth = self.size.width
        let originalImageHeight = self.size.height
        let ratio = screenWidth/originalImageWidth
        let imageHeightInScreen = ratio * originalImageHeight

        let differenceBetweenTopAndStartOfImage = (screenHeight - imageHeightInScreen) / 2
        UIGraphicsBeginImageContextWithOptions(CGSize(width: screenWidth, height: screenWidth), false, 0.0)
        let ctx = UIGraphicsGetCurrentContext()!
        let y = ((screenWidth - imageHeightInScreen - differenceBetweenTopAndStartOfImage) * 0.5)
        ctx.translateBy(x: 0,y: y)
        self.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: screenWidth, height: imageHeightInScreen)))
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

extension UIViewController{
     func presentAlertController(title: String, message: String) {
        let alertController = getAlertWith(title: title, message: message)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func getAlertWith(title: String, message: String) -> UIAlertController{
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        return alertController
    }
}


extension Notification.Name{
    static let didChangeOverlaySettings = NSNotification.Name(rawValue: "settingsDidChange")
    static let didCaptureItem =  NSNotification.Name(rawValue: "_UIImagePickerControllerUserDidCaptureItem")
    static let didRejectItem =  NSNotification.Name(rawValue: "_UIImagePickerControllerUserDidRejectItem")
}

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
        let statusBarHeight = CGFloat(UserDefaults.standard.float(forKey: "statusBarHeight"))
        let differenceBetweenTopAndStartOfImage = (screenHeight - imageHeightInScreen) / 2 - statusBarHeight
        UIGraphicsBeginImageContextWithOptions(CGSize(width: screenWidth, height: screenWidth), false, 0.0)
        let ctx = UIGraphicsGetCurrentContext()!
        let y = (-1 * differenceBetweenTopAndStartOfImage)
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

extension NSLayoutConstraint {
    /**
     Change multiplier constraint
     
     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
     */
    @discardableResult func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}

extension UIView {
    class func loadFromNib<T>(withName nibName: String) -> T? {
        let nib  = UINib.init(nibName: nibName, bundle: nil)
        let nibObjects = nib.instantiate(withOwner: nil, options: nil)
        for object in nibObjects {
            if let result = object as? T {
                return result
            }
        }
        return nil
    }
}

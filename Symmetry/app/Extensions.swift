//
//  NSUserDefaults+UIColor.swift
//  Symmetry
//
//  Created by Ahmed Allam on 3/31/19.
//  Copyright © 2019 Ahmed Allam. All rights reserved.
//

import UIKit
import SwiftyCam

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
    
    func overlaySizeImage() -> UIImage{
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        let width = self.size.width
        let height = self.size.height
        let ratio = screenWidth/width
        
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: screenWidth, height: screenHeight * 0.75), false, 0.0)
        let ctx = UIGraphicsGetCurrentContext()!
        let y = -1 * (screenHeight * 0.08)
        ctx.translateBy(x: 0,y: y)
        self.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: screenWidth, height: height * ratio)))
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    private func getImageOrientation(forCamera: SwiftyCamViewController.CameraSelection, deviceOrientaion: UIDeviceOrientation) -> UIImage.Orientation {
        
        switch deviceOrientaion {
        case .landscapeLeft:
            return forCamera == .rear ? .up : .downMirrored
        case .landscapeRight:
            return forCamera == .rear ? .down : .upMirrored
        case .portraitUpsideDown:
            return forCamera == .rear ? .left : .rightMirrored
        default:
            return forCamera == .rear ? .right : .leftMirrored
        }
    }
    
    func processImage(forCamera camera: SwiftyCamViewController.CameraSelection, imageType type: ImageType) -> UIImage{
        let width = self.size.width
        let height = self.size.height
        
        if height > width{
            return processPortraitImage(imageType: type)
        }else{
            return processLandscapeImage(forCamera: camera, imageType: type)
        }
        
    }
    
    private func processPortraitImage(imageType type: ImageType) -> UIImage{
        
        if type == .square{
            return squareImage()
        }else if type == .photo{
            return self
//            return overlaySizeImage()
        }else{
            return UIImage()
        }
    }
    
    private func processLandscapeImage(forCamera camera: SwiftyCamViewController.CameraSelection, imageType type: ImageType) -> UIImage{
        // crop the photo in portrait mode to calculate perfect
        let image = UIImage(cgImage: self.cgImage!, scale: 1.0, orientation: getImageOrientation(forCamera: camera, deviceOrientaion: .portrait))
        let croppedImage = image.processPortraitImage(imageType: type)
        
        //rotate photo again to its landscape mode
        let photo = UIImage(cgImage: croppedImage.cgImage!, scale: 1.0, orientation: .left)
        return photo
    }
}


enum ImageType {
    case square
    case photo
    case video
}

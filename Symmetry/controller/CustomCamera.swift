//
//  CustomCamera.swift
//  Symmetry
//
//  Created by Ahmed Allam on 1/20/19.
//  Copyright © 2019 Allam. All rights reserved.
//

import UIKit

class CustomCamera: UIImagePickerController{
    override func viewDidLayoutSubviews() {
        if let bottomBarView = self.view.findFirstSubview("CAMBottomBar"){
            print("bottom bar height: \(bottomBarView.frame.height)")
        }
    }
 
}

extension UIView {
    func findFirstSubview(_ className:String) -> UIView? {
        for subview in self.subviewsRecursive() {
            print(subview.className(),subview.frame.height )
            if subview.className() == className {
                return subview
            }
        }
        return nil
    }
    
    func subviewsRecursive() -> [UIView] {
        return subviews + subviews.flatMap { $0.subviewsRecursive() }
    }
}

extension NSObject {
    func className() -> String {
        return String(describing: type(of: self))
    }
}

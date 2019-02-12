//
//  RoundedCorenerView.swift
//  Symmetry
//
//  Created by Ahmed Allam on 2/9/19.
//  Copyright © 2019 Allam. All rights reserved.
//

import UIKit

class RoundedCornerView: UIView {
  
    override func draw(_ rect: CGRect) {
        
        self.layer.cornerRadius = 10.0
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 1
        self.layer.shadowColor = UIColor.black.cgColor;
        self.layer.shadowOffset = CGSize.zero;
        self.layer.shadowRadius = 5.0;
        self.layer.shadowOpacity = 0.5;
        self.clipsToBounds = true
        super.draw(rect)
    }
}

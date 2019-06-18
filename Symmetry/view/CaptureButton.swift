//
//  CaptureButton.swift
//  Symmetry
//
//  Created by Ahmed Allam on 6/17/19.
//  Copyright © 2019 Ahmed Allam. All rights reserved.
//

import UIKit

class CaptureButtonView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func roundCorners() {
        self.layer.cornerRadius = self.frame.height / 2
        layer.masksToBounds = true
        self.backgroundColor = .white
    }
    
    
    private func commonInit() {
        let buttonSize: CGFloat = 50.0
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        button.backgroundColor = .white
        button.layer.cornerRadius = buttonSize / 2
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 50),
            button.heightAnchor.constraint(equalToConstant: 50),
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
    }
    
}

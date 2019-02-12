//
//  OverlayView.swift
//  Symmetry
//
//  Created by Allam on 11/9/18.
//  Copyright © 2018 Allam. All rights reserved.
//

import UIKit

class OverlayView{
    let defaults = UserDefaults.standard
    var delegate: OverLayViewDelegate?
    
    init(delegate: OverLayViewDelegate) {
        self.delegate = delegate
    }
    
    func getOverlayView(frame: CGRect) -> UIView{
        let shape = getOverlayShapeChoiseFromDefaults()
        var view: UIView!
        switch shape {
        case .grid:
            view = GridView(frame: frame)
        case .circle:
            view = CircleView(frame: frame)
        }
        addSettingsButton(to: view)
        view.backgroundColor = UIColor.clear
        return view
    }
    

    
    private func getOverlayShapeChoiseFromDefaults() -> OverlayShape{
        let isGrid = defaults.bool(forKey: SettingsKeys.isGrid.rawValue)
        return isGrid ? OverlayShape.grid : OverlayShape.circle
    }
    
    private func addSettingsButton(to overlayView: UIView){
        let frameWidth = overlayView.frame.size.width
        let settingIconPosition = CGPoint(x: frameWidth - 38, y: 8)
        let settingIconSize:CGFloat = 32
        
        // add settings button on uper right
        let button = UIButton(frame: CGRect(x: settingIconPosition.x, y: settingIconPosition.y, width: settingIconSize, height: settingIconSize))
        button.setImage(#imageLiteral(resourceName: "settings"), for: .normal)
        button.addTarget(self, action: #selector(settingButtonAction(_:)), for: .touchUpInside)
        overlayView.addSubview(button)
        addConstraints(to: button, with: overlayView)

    }
    
    private func addConstraints(to button: UIButton, with superView: UIView){
        let margins = superView.layoutMarginsGuide
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: margins.topAnchor, constant: 0),
            button.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 0),
            button.widthAnchor.constraint(equalTo: button.heightAnchor, constant: 32)
            ])
    }
    
    @objc func settingButtonAction(_ sender: UIButton!) {
        delegate?.didPressSettingsButton()
    }
}

protocol OverLayViewDelegate {
    func didPressSettingsButton()
}

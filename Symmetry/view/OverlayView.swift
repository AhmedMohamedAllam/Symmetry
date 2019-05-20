//
//  OverlayView.swift
//  Symmetry
//
//  Created by Allam on 11/9/18.
//  Copyright © 2018 Allam. All rights reserved.
//

import UIKit
protocol OverLayViewDelegate {
    func didPressSettingsButton()
}

let overlayViewTag = 1000

class OverlayView{
    var delegate: OverLayViewDelegate?
    init(delegate: OverLayViewDelegate) {
        self.delegate = delegate
    }
    
    private func drawOverlayShape(frame: CGRect) -> UIView{
        let shape = getOverlayShapeChoiseFromDefaults()
        let currentFrame = getCorrectFrameSizeIfSquare(fromOriginal: frame)
        var view: UIView!
        switch shape {
        case .grid:
            view = GridView(frame: currentFrame)
        case .circle:
            view = CircleView(frame: currentFrame)
        }
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func getOverlayView(frame: CGRect) -> UIView{
        //the circles and grid only
        let overlayShape = drawOverlayShape(frame: frame)
        overlayShape.tag = overlayViewTag
        let overlayView = UIView(frame: frame)
        overlayShape.isUserInteractionEnabled = false
        overlayView.addSubview(overlayShape)
        addLowerAndUpperViews(to: overlayView)
        overlayView.layoutSubviews()
        addSettingsButton(to: overlayView)
        return overlayView
    }
    
    func getCorrectFrameSizeIfSquare(fromOriginal frame: CGRect) -> CGRect {
        let isSquare = UserDefaults.standard.bool(forKey: SettingsKeys.isSquared.rawValue)
        let currentFrame = isSquare ? squareFrame(from: frame) : frame
        return currentFrame
    }
    
    
    private func squareFrame(from frame: CGRect) -> CGRect{
        let dimensions = squareDimensions(from: frame)
        return CGRect(x: 0, y: dimensions["y"]!, width: dimensions["shortDimension"]!, height: dimensions["shortDimension"]!)
    }
    
    //return (short dimension, y)
    private func squareDimensions(from frame: CGRect) -> [String: CGFloat]{
        let shortDimension = frame.width < frame.height ? frame.width : frame.height
        let longDimension = frame.width > frame.height ? frame.width : frame.height
        
        let y = (longDimension - shortDimension) / 2
        return ["y": y, "shortDimension": shortDimension]
    }
    
    
    private func getOverlayShapeChoiseFromDefaults() -> OverlayShape{
        let isGrid = UserDefaults.standard.bool(forKey: SettingsKeys.isGrid.rawValue)
        return isGrid ? OverlayShape.grid : OverlayShape.circle
    }
    
    private func  addLowerAndUpperViews(to view: UIView){
        //the upper and lower part in the case of sqare images
        let upperView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
        let lowerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
        
        upperView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        lowerView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        lowerView.isUserInteractionEnabled = false
        upperView.isUserInteractionEnabled = false
        
        view.addSubview(lowerView)
        view.addSubview(upperView)
        
        lowerView.translatesAutoresizingMaskIntoConstraints = false
        upperView.translatesAutoresizingMaskIntoConstraints = false
        
        
        let dimensions = squareDimensions(from: view.frame)
        
        NSLayoutConstraint.activate([
            upperView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            upperView.heightAnchor.constraint(equalToConstant: dimensions["y"]!),
            upperView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            upperView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])
        
        NSLayoutConstraint.activate([
            lowerView.heightAnchor.constraint(equalToConstant: dimensions["y"]!),
            lowerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            lowerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lowerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])
    }
    
    private func addSettingsButton(to overlayView: UIView){
//        let frameWidth = overlayView.frame.size.width
        let settingIconPosition = CGPoint(x: 0, y: 0)
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
            button.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 16),
            button.widthAnchor.constraint(equalTo: button.heightAnchor, constant: 32)
            ])
    }
    
    @objc func settingButtonAction(_ sender: UIButton!) {
        delegate?.didPressSettingsButton()
    }

}

//
//  CircleView.swift
//  Symmetry
//
//  Created by Allam on 11/3/18.
//  Copyright © 2018 Allam. All rights reserved.
//

import Foundation
import UIKit

class CircleView: UIView{
    let defaults = UserDefaults.standard
    
    @IBInspectable var numberOfCircles: Int = 5
    @IBInspectable var lineWidth: CGFloat = 1.0
    @IBInspectable var lineColor: UIColor = UIColor.white
    @IBInspectable var fillColor: UIColor = UIColor.clear
    @IBInspectable var centeredLines: Bool = true
    @IBInspectable var crossedLines: Bool = true
    @IBInspectable var transperency: CGFloat = 1.0 {
        didSet{
            self.alpha = transperency
        }
    }
   
    func configureViewFromUserDefaults() {
        let lineWidth = CGFloat(defaults.integer(forKey: SettingsKeys.lineWidth.rawValue))
        self.lineWidth = lineWidth > 0 ? lineWidth : 1.0
        let  lineColor = defaults.string(forKey: SettingsKeys.lineColor.rawValue)
        self.lineColor = OverlayViewConfiguration.getColor(from: lineColor)
        
        let numberOfCircles = defaults.integer(forKey: SettingsKeys.numberOfCircles.rawValue)
        self.numberOfCircles = numberOfCircles > 0 ? numberOfCircles : 5
        
         centeredLines = defaults.bool(forKey: SettingsKeys.showCenterLines.rawValue)
         crossedLines = defaults.bool(forKey: SettingsKeys.showCrossLines.rawValue)
        backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        configureViewFromUserDefaults()
        
        let width = rect.width
        let hieght = rect.height
        
        if let context = UIGraphicsGetCurrentContext(){
            context.setLineWidth(lineWidth)
            context.setStrokeColor(lineColor.cgColor)
            guard numberOfCircles > 0 else{
                return
            }
            
            //choose the small dimension to not draw half circles
            let smallDimension = width < hieght ? width : hieght
            //divide screen equally between circles with factor
            let radiusFactor = ((smallDimension / 2) / CGFloat(numberOfCircles))
            
            //draw circles
            for i in 1...numberOfCircles{
                let radius = (radiusFactor * CGFloat(i))
                context.addArc(center: center, radius: radius, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
                context.strokePath()
            }
            
            if centeredLines{
                drawCenterLines(with: context, to: rect)
            }
            if crossedLines{
                drawCrossLines(with: context, to: rect)
            }
        }
        
    }
    
    func drawLine(with context: CGContext, startPoint: CGPoint, endPoint: CGPoint){
        context.move(to: startPoint)
        context.addLine(to: endPoint)
        context.strokePath()
    }
    
    func drawCenterLines(with context: CGContext, to rect: CGRect) {
        let width = rect.width
        let hieght = rect.height
        
        var verticatlStartPoint = CGPoint.zero
        var verticatlEndPoint = CGPoint.zero
        
        //vertical Line start:(x/2, 0) end:(x/2, y)
        verticatlStartPoint.x = width / 2
        verticatlStartPoint.y = 0

        verticatlEndPoint.x = width / 2
        verticatlEndPoint.y = hieght
        drawLine(with: context, startPoint: verticatlStartPoint, endPoint: verticatlEndPoint)
        
        var horizontalStartPoint = CGPoint.zero
        var horizontalEndPoint = CGPoint.zero
        
        //horizontal Line start:(0, y/2) end:(x, y/2)

        horizontalStartPoint.x = 0
        horizontalStartPoint.y = hieght / 2
        
        horizontalEndPoint.x = width
        horizontalEndPoint.y = hieght / 2
        drawLine(with: context, startPoint: horizontalStartPoint, endPoint: horizontalEndPoint)
    }
    
    func drawCrossLines(with context: CGContext, to rect: CGRect) {
        let width = rect.width
        let hieght = rect.height
        
        let leftStartPoint = CGPoint.zero
        var leftEndPoint = CGPoint.zero
        
        //vertical Line start:(0, 0) end:(x, y)
        leftEndPoint.x = width
        leftEndPoint.y = hieght
        drawLine(with: context, startPoint: leftStartPoint, endPoint: leftEndPoint)
        
        var rightStartPoint = CGPoint.zero
        var rightEndPoint = CGPoint.zero
        
        //horizontal Line start:(x, 0) end:(y, 0)
        
        rightStartPoint.x = width
        rightStartPoint.y = 0
        
        rightEndPoint.x = 0
        rightEndPoint.y = hieght
        drawLine(with: context, startPoint: rightStartPoint, endPoint: rightEndPoint)
    }
}

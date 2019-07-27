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
    var gridCellNumber: CellCoordinate!

    
    @IBInspectable var numberOfCircles: Int = 5
    @IBInspectable var lineWidth: CGFloat = 1.0
    @IBInspectable var lineColor: UIColor = UIColor.white
    @IBInspectable var fillColor: UIColor = UIColor.clear
    @IBInspectable var centeredDashedLines: Bool = true
    @IBInspectable var crossedLines: Bool = true
    @IBInspectable var transperency: CGFloat = 1.0 {
        didSet{
            self.alpha = transperency
        }
    }
   
    func configureViewFromUserDefaults() {
        let lineWidth = CGFloat(defaults.integer(forKey: SettingsKeys.lineWidth.rawValue))
        self.lineWidth = lineWidth > 0 ? lineWidth : 1.0
        self.lineColor = defaults.color(forKey: SettingsKeys.lineColor.rawValue) 
        
        let numberOfCircles = defaults.integer(forKey: SettingsKeys.numberOfCircles.rawValue)
        self.numberOfCircles = numberOfCircles > 0 ? numberOfCircles : 5
        
         centeredDashedLines = defaults.bool(forKey: SettingsKeys.showCenteredDashedLines.rawValue)
         crossedLines = defaults.bool(forKey: SettingsKeys.showCrossLines.rawValue)
        backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        configureViewFromUserDefaults()
        gridCellNumber = CellCoordinate(circles: numberOfCircles)

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
                let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
                context.addArc(center: center, radius: radius, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
                context.strokePath()
            }
            
            let circleLinesCount = numberOfCircles * 2
            for i in 0..<circleLinesCount{
                addHorizontalCellNumbers(index: i, radius: radiusFactor)
            }

            for i in 0..<circleLinesCount{
                addVetictalCellNumbers(index: i, radius: radiusFactor)
            }
            
            drawCenterLines(with: context, to: rect, isDashed: centeredDashedLines)
            
            if crossedLines{
                drawCrossLines(with: context, to: rect)
            }
        }
        
    }
    
    func drawLine(with context: CGContext, startPoint: CGPoint, endPoint: CGPoint , isDashed: Bool){
        context.move(to: startPoint)
        context.addLine(to: endPoint)
        if isDashed{
            context.setLineDash(phase: 3, lengths: [5,5])
        }else{
            context.setLineDash(phase: 0, lengths: [])
        }
        context.strokePath()
    }
    
    func drawCenterLines(with context: CGContext, to rect: CGRect, isDashed: Bool) {
        let width = rect.width
        let hieght = rect.height
        
        var verticatlStartPoint = CGPoint.zero
        var verticatlEndPoint = CGPoint.zero
        
        //vertical Line start:(x/2, 0) end:(x/2, y)
        verticatlStartPoint.x = width / 2
        verticatlStartPoint.y = 0

        verticatlEndPoint.x = width / 2
        verticatlEndPoint.y = hieght
        drawLine(with: context, startPoint: verticatlStartPoint, endPoint: verticatlEndPoint, isDashed: isDashed)
        
        var horizontalStartPoint = CGPoint.zero
        var horizontalEndPoint = CGPoint.zero
        
        //horizontal Line start:(0, y/2) end:(x, y/2)

        horizontalStartPoint.x = 0
        horizontalStartPoint.y = hieght / 2
        
        horizontalEndPoint.x = width
        horizontalEndPoint.y = hieght / 2
        drawLine(with: context, startPoint: horizontalStartPoint, endPoint: horizontalEndPoint, isDashed: isDashed)
    }
    
    func drawCrossLines(with context: CGContext, to rect: CGRect) {
        let width = rect.width
        let hieght = rect.height
        
        let leftStartPoint = CGPoint.zero
        var leftEndPoint = CGPoint.zero
        
        //vertical Line start:(0, 0) end:(x, y)
        leftEndPoint.x = width
        leftEndPoint.y = hieght
        drawLine(with: context, startPoint: leftStartPoint, endPoint: leftEndPoint, isDashed: false)
        
        var rightStartPoint = CGPoint.zero
        var rightEndPoint = CGPoint.zero
        
        //horizontal Line start:(x, 0) end:(y, 0)
        
        rightStartPoint.x = width
        rightStartPoint.y = 0
        
        rightEndPoint.x = 0
        rightEndPoint.y = hieght
        drawLine(with: context, startPoint: rightStartPoint, endPoint: rightEndPoint, isDashed: false)
    }
    
    private func cellLabel(with number: Int) -> UILabel{
        let label = UILabel(frame: CGRect(x: 100, y: 0, width: 20, height: 20))
        label.text = "\(number)"
        label.textColor = lineColor
        label.textAlignment = .center
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func addHorizontalCellNumbers(index: Int, radius: CGFloat){
        let isCircleNumbersShown = defaults.value(forKey: SettingsKeys.showCircleNumbers.rawValue) as? Bool
        
        guard isCircleNumbersShown ?? true else {
            return
        }
        let number = gridCellNumber.horizontalNumbers [index]
        if number == 0 {return}
        let label = cellLabel(with: number)
        let xConstant = radius * CGFloat(index) - radius / 2 - ((CGFloat(numberOfCircles) - 1) * radius)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: xConstant ),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -8)
            ])
    }
    
    private func addVetictalCellNumbers(index: Int, radius: CGFloat){
        let isCircleNumbersShown = defaults.value(forKey: SettingsKeys.showCircleNumbers.rawValue) as? Bool
        guard isCircleNumbersShown ?? true else {
            return
        }
        let number = gridCellNumber.verticalNumbers[index]
        if number == 0 {return}
        let label = cellLabel(with: number)
        let yConstant = radius * CGFloat(index) - radius / 2 - ((CGFloat(numberOfCircles) - 1) * radius)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: -8),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: yConstant)
            ])
    }
    
}

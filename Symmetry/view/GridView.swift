//
//  GridView.swift
//  Symmetry
//
//  Created by Allam on 11/3/18.
//  Copyright © 2018 Allam. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class GridView: UIView {
    let defaults = UserDefaults.standard
    var gridCellNumber: GridCellNumber!
    
    @IBInspectable var numberOfColumns: Int = 2
    @IBInspectable var numberOfRows: Int = 2
    @IBInspectable var lineWidth: CGFloat = 1.0
    @IBInspectable var lineColor: UIColor = UIColor.white
    @IBInspectable var transperency: CGFloat = 1.0 {
        didSet{
            self.alpha = transperency
        }
    }
    
    func configureViewFromUserDefaults() {
        let lineWidth = CGFloat(defaults.integer(forKey: SettingsKeys.lineWidth.rawValue))
        self.lineWidth = lineWidth > 0 ? lineWidth : 1.0
        let lineColor = defaults.string(forKey: SettingsKeys.lineColor.rawValue)
        self.lineColor = OverlayViewConfiguration.getColor(from: lineColor)
        let columns = defaults.integer(forKey: SettingsKeys.numberOfColumns.rawValue)
        self.numberOfColumns = columns > 0 ? columns : 3
        let rows = defaults.integer(forKey: SettingsKeys.numberOfRows.rawValue)
        self.numberOfRows = rows > 0 ? rows : 3
        backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        configureViewFromUserDefaults()
        gridCellNumber = GridCellNumber(columns: numberOfColumns, rows: numberOfRows)
        
        if let context = UIGraphicsGetCurrentContext() {
            
            context.setLineWidth(lineWidth)
            context.setStrokeColor(lineColor.cgColor)
            // draw the frame rectangle line first
            context.stroke(rect)
            
            //draw vertical lines
            let columnWidth = rect.width / CGFloat(numberOfColumns + 1)
            for column in 1...numberOfColumns {
                var startPoint = CGPoint.zero
                var endPoint = CGPoint.zero
                startPoint.x = columnWidth * CGFloat(column)
                startPoint.y = 0.0
                endPoint.x = startPoint.x
                endPoint.y = frame.size.height
                let isDashed = canDrawDashLine(lines: numberOfColumns, currentLine: column)
                drawLine(with: context, startPoint: startPoint, endPoint: endPoint, isDashed: isDashed)
               addHorizontalCellNumbers(index: column, x: startPoint.x, columnWidth: columnWidth)
            }
            
            //draw horizontal lines
            let rowHeight = rect.height / CGFloat(numberOfRows + 1)
            for row in 1...numberOfRows {
                var startPoint = CGPoint.zero
                var endPoint = CGPoint.zero
                startPoint.x = 0.0
                startPoint.y = rowHeight * CGFloat(row)
                endPoint.x = frame.size.width
                endPoint.y = startPoint.y
                let isDashed = canDrawDashLine(lines: numberOfRows, currentLine: row)
                drawLine(with: context, startPoint: startPoint, endPoint: endPoint, isDashed: isDashed)
                addVetictalCellNumbers(index: row, y: startPoint.y, rowHeight: rowHeight)
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
    
    private func drawSolidLine(with context: CGContext, startPoint: CGPoint, endPoint: CGPoint){
        context.move(to: startPoint)
        context.addLine(to: endPoint)
        context.strokePath()
    }
    
    private func canDrawDashLine(lines: Int, currentLine: Int) -> Bool{
        guard defaults.bool(forKey: SettingsKeys.showDashedLines.rawValue) else {
            return false
        }
        return isOdd(lines) && isCenterLine(lines: lines, currentLine: currentLine)
    }
    
    private func isOdd(_ lines: Int) -> Bool{
        return lines > 4 && lines % 2 != 0
    }
    
    private func isCenterLine(lines: Int, currentLine: Int) -> Bool{
        let center = (lines / 2) + 1
        return center == currentLine
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
    
    private func addHorizontalCellNumbers(index: Int, x: CGFloat, columnWidth: CGFloat){
        let number = gridCellNumber.horizontalNumbers [index]
        let label = cellLabel(with: number)
        let xConstant = x + (columnWidth / 2.0)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.leadingAnchor, constant: xConstant ),
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 4)
            ])
    }
    
    private func addVetictalCellNumbers(index: Int, y: CGFloat, rowHeight: CGFloat){
        let number = gridCellNumber.verticalNumbers[index]
        let label = cellLabel(with: number)
        let yConstant = y + (rowHeight / 2.0)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 2),
            label.centerYAnchor.constraint(equalTo: self.topAnchor, constant: yConstant)
            ])
    }
    
}

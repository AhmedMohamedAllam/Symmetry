//
//  GridCellNumber.swift
//  Symmetry
//
//  Created by Ahmed Allam on 2/22/19.
//  Copyright © 2019 Ahmed Allam. All rights reserved.
//

import Foundation

struct CellCoordinate {
    var horizontalNumbers: [Int]!
    var verticalNumbers: [Int]!
    
    var isGridView: Bool
    
    init(columns: Int, rows: Int) {
        isGridView = true
        horizontalNumbers = divideNumbers(numbers: columns)
        verticalNumbers = divideNumbers(numbers: rows)
    }
    
    init(circles: Int) {
        isGridView = false
        horizontalNumbers = divideNumbersForCircles(numberOfCircles: circles * 2)
        verticalNumbers = divideNumbersForCircles(numberOfCircles: circles * 2)
    }
    
    
    func divideNumbers(numbers: Int) -> [Int] {
        var mid = (numbers / 2) + 1
        
        //if is circle add 1 to the mid
        mid = isGridView ? mid : mid + 1
        var devidedNumbers = [Int]()
        //add first half
        let reversedNumbersRange = (1...mid).reversed()
        for i in reversedNumbersRange{
            devidedNumbers.append(i)
        }
        
        //if number of colums is even and is grid remove last item which is '1' to not repeat '1' again
        //or is circle
        if (isGridView && numbers % 2 == 0) || !isGridView {
            devidedNumbers.removeLast()
        }
        
        
        for i in 1...mid{
            devidedNumbers.append(i)
        }
        
        return devidedNumbers
    }
    
    func divideNumbersForCircles(numberOfCircles: Int) -> [Int] {
        var mid = (numberOfCircles / 2) - 1
        
        
        var devidedNumbers = [Int]()
        //add first half
        let reversedNumbersRange = (0...mid).reversed()
        for i in reversedNumbersRange{
            devidedNumbers.append(i)
        }
                
        for i in 0...mid{
            devidedNumbers.append(i)
        }
        
        return devidedNumbers
    }

    
}

//
//  GridCellNumber.swift
//  Symmetry
//
//  Created by Ahmed Allam on 2/22/19.
//  Copyright © 2019 Ahmed Allam. All rights reserved.
//

import Foundation

struct GridCellNumber {
    var horizontalNumbers: [Int]!
    var verticalNumbers: [Int]!
    
    init(columns: Int, rows: Int) {
        horizontalNumbers = divideNumbers(numbers: columns)
        verticalNumbers = divideNumbers(numbers: rows)
//        // if rows == columns add
//        if rows == columns{
//            horizontalNumbers.insert((columns / 2) + 1, at: 0)
//        }
    }
    
    func divideNumbers(numbers: Int) -> [Int] {
        let mid = (numbers / 2) + 1
        var devidedNumbers = [Int]()
        //add first half
        let reversedNumbersRange = (1...mid).reversed()
        for i in reversedNumbersRange{
            devidedNumbers.append(i)
        }
        
        //if number of colums is even remove last item which is '1' to not repeat '1' again
        if numbers % 2 == 0{
            devidedNumbers.removeLast()
        }
        
        for i in 1...mid{
            devidedNumbers.append(i)
        }
        
        return devidedNumbers
    }
    
}

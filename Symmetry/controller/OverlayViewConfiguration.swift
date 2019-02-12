//
//  OverlayViewConfiguration.swift
//  Symmetry
//
//  Created by Allam on 11/3/18.
//  Copyright © 2018 Allam. All rights reserved.
//

import Foundation
import UIKit

class OverlayViewConfiguration{
    
    static func getColor(from string: String?) -> UIColor{
        switch string {
        case "white":
            return UIColor.white
        case "black":
            return UIColor.black
        case "red":
            return UIColor.red
        case "green":
            return UIColor.green
        case "blue":
            return UIColor.blue
        case "yellow":
            return UIColor.yellow
        default:
            return UIColor.white
        }
    }

}


enum OverlayShape {
    case grid
    case circle
}

extension String{
    func color() -> UIColor{
        return OverlayViewConfiguration.getColor(from: self)
    }
}

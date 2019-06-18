//
//  OverlayView.swift
//  Symmetry
//
//  Created by Allam on 11/9/18.
//  Copyright © 2018 Allam. All rights reserved.
//

import UIKit

class OverlayView{
   
    init() {}
    
    static func overlayShape(with frame: CGRect) -> UIView{
        let shape = getOverlayShapeChoiseFromDefaults()
        var view: UIView!
        switch shape {
        case .grid:
            view = GridView(frame: frame)
        case .circle:
            view = CircleView(frame: frame)
        }
        view.backgroundColor = UIColor.clear
        return view
    }
    
    private static func getOverlayShapeChoiseFromDefaults() -> OverlayShape{
        let isGrid = UserDefaults.standard.bool(forKey: SettingsKeys.isGrid.rawValue)
        return isGrid ? OverlayShape.grid : OverlayShape.circle
    }
}

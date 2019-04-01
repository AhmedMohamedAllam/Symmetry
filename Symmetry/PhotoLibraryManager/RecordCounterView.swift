//
//  RecordCounterView.swift
//  StoryMateCamera
//
//  Created by Ahmed Allam on 2/25/19.
//  Copyright © 2019 TheD. GmbH. All rights reserved.
//

import UIKit

class RecordCounterView: UIView {
    
    @IBOutlet weak var redDotView: UIView!
    @IBOutlet weak var counterText: UILabel!
    
    private var startTime: TimeInterval?
    
    private var timer: Timer!
    
    
    
    override func layerWillDraw(_ layer: CALayer) {
        super.layerWillDraw(layer)
        redDotView.layer.cornerRadius = redDotView.frame.height / 2
    }
    
    func startCounter() {
        startTime = Date().timeIntervalSinceReferenceDate
        fireTimer()
    }
    
    
    func stopCounter() {
        timer.invalidate()
        counterText.text = "00:00:00"
    }
    
    private func fireTimer(){
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){[weak self] timer in
            let elapsedTime = Date().timeIntervalSinceReferenceDate - (self?.startTime!)!
            let elapsedTimeFormatted = elapsedTime.stringFromTimeInterval()
            DispatchQueue.main.async {
                self?.counterText.text = elapsedTimeFormatted
            }
        }
    }
    
    
    
}

extension TimeInterval{
    func stringFromTimeInterval() -> String {

        let time = NSInteger(self)
        
        let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        return String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds,ms)
        
    }
}

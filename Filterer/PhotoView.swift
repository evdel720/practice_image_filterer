//
//  PhotoView.swift
//  Filterer
//
//  Created by Jo Jangmi on 12/25/16.
//  Copyright © 2016 Jo Jangmi. All rights reserved.
//

import UIKit

class PhotoView: UIImageView {
    var lastTouchTime: NSDate? = nil
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        let currentTime = NSDate()
        if let prevTime = lastTouchTime {
            if currentTime.timeIntervalSinceDate(prevTime) < 0.5 {
                print("double tapped!")
                lastTouchTime = nil
                return;
            }
        }
        lastTouchTime = currentTime
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
    }
}

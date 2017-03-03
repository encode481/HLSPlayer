//
//  DragNDropView.swift
//  HLSTask
//
//  Created by PavelKnd on 3/3/17.
//  Copyright © 2017 PavelKnd. All rights reserved.
//

import UIKit

class DragNDropView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(DragNDropView.handlePanGesture(gesture:)))
        self.addGestureRecognizer(panGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let halfWidth = self.bounds.width / 2
        let halfHeight = self.bounds.height / 2
        let translation = gesture.translation(in: self.superview)
        
        
        var finalPoint = CGPoint(x:gesture.view!.center.x + translation.x,
                                 y:gesture.view!.center.y + translation.y)
        finalPoint.x = min(max(finalPoint.x, 0 + halfWidth), (self.superview?.frame.size.width)! - halfWidth)
        finalPoint.y = min(max(finalPoint.y, 0 + halfHeight), (self.superview?.frame.size.height)! - halfHeight)
        
        gesture.view!.center = finalPoint
        
        gesture.setTranslation(CGPoint.zero, in: self.superview)
        switch gesture.state {
        case .began:
            
            self.layer.removeAllAnimations()
        case .changed:
            self.layer.removeAllAnimations()
        case .ended:
            
            let velocity = gesture.velocity(in: self.superview)
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            let slideMultiplier = magnitude / 600
            
            
            let slideFactor = 0.1 * slideMultiplier
            
            
            
            var finalPoint = CGPoint(x:gesture.view!.center.x + (velocity.x * slideFactor),
                                     y:gesture.view!.center.y + (velocity.y * slideFactor))
            
            finalPoint.x = min(max(finalPoint.x, 0 + halfWidth), (self.superview?.frame.size.width)! - halfWidth)
            finalPoint.y = min(max(finalPoint.y, 0 + halfHeight), (self.superview?.frame.size.height)! - halfHeight)
            
            UIView.animate(withDuration: Double(slideFactor * 2),
                           delay: 0,
                           options: [.curveEaseOut, .allowUserInteraction],
                           animations: {
                            gesture.view!.center = finalPoint
            }, completion: nil)
            
        default: break
            
        }
    }
}

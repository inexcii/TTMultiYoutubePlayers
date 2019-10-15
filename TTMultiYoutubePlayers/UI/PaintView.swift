//
//  PaintView.swift
//  TTMultiYoutubePlayers
//
//  Created by Yuan Zhou on 2019/10/15.
//  Copyright © 2019 GEN SHU. All rights reserved.
//

import UIKit

class PaintView: UIView {
    
    private var pointBegin: CGPoint?
    private var pointEnd: CGPoint?
    private var drawedLayers = [CAShapeLayer]()
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: self)
            
            if pointBegin == nil && pointEnd == nil {
                pointBegin = point
            } else if pointEnd == nil {
                pointEnd = point
                drawLine()
                pointBegin = nil
                pointEnd = nil
            }
        }
    }
    
    // MARK: - Internal
    
    /// Undo last painted object
    func undo() {
        let lastLayer = drawedLayers.popLast()
        lastLayer?.removeFromSuperlayer()
    }
    
    // MARK: - Private
    
    private func drawLine() {
        let layer = CAShapeLayer()
        layer.path = getPath().cgPath
        layer.strokeColor = UIColor.red.cgColor
        layer.lineWidth = 2.0
        self.layer.addSublayer(layer)
        
        drawedLayers.append(layer)
    }
    
    private func getPath() -> UIBezierPath {
        if let begin = pointBegin, let end = pointEnd {
            let aPath = UIBezierPath()
            aPath.move(to: begin)
            aPath.addLine(to: end)
            return aPath
        }
        
        print("not enough info for creating a path")
        return UIBezierPath()
    }
}

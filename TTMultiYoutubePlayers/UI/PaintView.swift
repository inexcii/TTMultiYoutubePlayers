//
//  PaintView.swift
//  TTMultiYoutubePlayers
//
//  Created by Yuan Zhou on 2019/10/15.
//  Copyright © 2019 GEN SHU. All rights reserved.
//

import UIKit

protocol PaintViewDelegate: AnyObject {
    func didGenerateLineAngle(angle: Double, view: PaintView)
}

class PaintView: UIView {
    
    weak var delegate: PaintViewDelegate?
    
    private var pointBegin: CGPoint?
    private var layerLine: CAShapeLayer?
    private var drawedLayers = [CAShapeLayer]()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            pointBegin = touch.location(in: self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let end = touch.location(in: self)
            if let begin = pointBegin {
                layerLine?.removeFromSuperlayer()
                drawLine(from: begin, to: end)
                
                let angle = Utility.calculateAngle(from: begin, to: end)
                self.delegate?.didGenerateLineAngle(angle: angle, view: self)
            } else {
                print("not enough info for creating a path")
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            if let layer = layerLine {
                drawedLayers.append(layer)
            }
            
            pointBegin = nil
            layerLine = nil
        }
    }
    
    // MARK: - Internal
    
    /// Undo last painted object
    func undo() {
        let lastLayer = drawedLayers.popLast()
        lastLayer?.removeFromSuperlayer()
    }
    
    // MARK: - Private
    
    private func drawLine(from begin: CGPoint, to end: CGPoint) {
        layerLine = CAShapeLayer()
        
        let path = UIBezierPath()
        path.move(to: begin)
        path.addLine(to: end)
        
        layerLine?.path = path.cgPath
        layerLine?.strokeColor = UIColor.red.cgColor
        layerLine?.lineWidth = 2.0
        
        if let layer = layerLine {
            self.layer.addSublayer(layer)
        }
    }
}

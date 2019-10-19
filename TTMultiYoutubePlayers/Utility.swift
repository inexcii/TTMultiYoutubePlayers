//
//  Utility.swift
//  TTMultiYoutubePlayers
//
//  Created by Yuan Zhou on 2019/10/19.
//  Copyright © 2019 GEN SHU. All rights reserved.
//

import UIKit

class Utility {
    
    static func calculateAngle(from begin: CGPoint, to end: CGPoint) -> Double {
        let angle = atan2(Double(abs(end.y - begin.y)), Double(abs(end.x - begin.x)))
        let piAngle = angle * (180.0/Double.pi)
        let digit2Angle = Double(round(piAngle * 100) / 100)
        
        return digit2Angle
    }
    
}

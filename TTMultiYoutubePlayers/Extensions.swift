//
//  Extensions.swift
//  TTMultiYoutubePlayers
//
//  Created by Yuan Zhou on 2019/10/09.
//  Copyright © 2019 GEN SHU. All rights reserved.
//

import Foundation
import AVFoundation

extension CMTime {
    func toDisplay() -> String {
        let totalSeconds = CMTimeGetSeconds(self)
        let secondsText = String(format: "%02d", Int(totalSeconds) % 60)
        let minutesText = String(format: "%02d", Int(totalSeconds) / 60)
        let hoursText = String(format: "%02d", Int(totalSeconds) / 60 / 60)
        return  "\(hoursText):\(minutesText):\(secondsText)"
    }
}

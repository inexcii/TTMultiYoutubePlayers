//
//  Extensions.swift
//  TTMultiYoutubePlayers
//
//  Created by Yuan Zhou on 2019/10/09.
//  Copyright © 2019 GEN SHU. All rights reserved.
//

import UIKit
import AVFoundation

extension CMTime {
    func toDisplay() -> String {
        let totalSeconds = CMTimeGetSeconds(self)
        let secondsText = String(format: "%02d", Int(totalSeconds) % 60)
        let decimal = totalSeconds.truncatingRemainder(dividingBy: 1)
        let secondsDecimal = String(format: "%02d", Int(round(decimal * 100)))
        let minutesText = String(format: "%02d", Int(totalSeconds) / 60)
        let hoursText = String(format: "%02d", Int(totalSeconds) / 60 / 60)
        return  "\(hoursText):\(minutesText):\(secondsText).\(secondsDecimal)"
    }
}

extension AVAsset {
    var frameRate: Float? {
        return self.tracks(withMediaType: .video).last?.nominalFrameRate
    }
}

extension UIView {
    func loadNib(nibName: String? = nil) {

        backgroundColor = .clear

        let bundle = Bundle(for: type(of: self))
        let nibName = nibName ?? "\(type(of: self))"
        let view = bundle.loadNibNamed(nibName, owner: self, options: nil)!.first as! UIView
        addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: leftAnchor),
            view.topAnchor.constraint(equalTo: topAnchor),
            view.rightAnchor.constraint(equalTo: rightAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

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
        guard CMTIME_IS_INDEFINITE(self) == false else { return "00:00:00" }

        let totalSeconds = CMTimeGetSeconds(self)
        let decimal = totalSeconds.truncatingRemainder(dividingBy: 1)
        let secondsDecimal = String(format: "%02d", Int(round(decimal * 100)))

        return "\(Int(totalSeconds).displayedTime).\(secondsDecimal)"
    }
}

// Int extension for calculating displayed time(hh:mm:ss)
extension Int {
    fileprivate var displayedTime: String {
        let hour = String(format: "%02d", secondsToHour)
        let minute = String(format: "%02d", secondsToMinute)
        let second = String(format: "%02d", secondsToSecond)
        return "\(hour):\(minute):\(second)"
    }

    private var secondsToHour: Int { return self / 60 / 60 }
    private var secondsToSecond: Int { return self % 60 }
    private var secondsToMinute: Int {
        let secondsOfHour = secondsToHour * 3600
        return (self - secondsOfHour) / 60
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

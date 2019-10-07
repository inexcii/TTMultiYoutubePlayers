//
//  AVPlayerView.swift
//  TTMultiYoutubePlayers
//
//  Created by Yuan Zhou on 2019/10/07.
//  Copyright © 2019 GEN SHU. All rights reserved.
//

import UIKit
import AVFoundation

class AVPlayerView: UIView {
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
}

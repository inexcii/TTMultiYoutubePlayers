//
//  VideoPlaying.swift
//  TTMultiYoutubePlayers
//
//  Created by Yuan Zhou on 2022/01/23.
//  Copyright © 2022 GEN SHU. All rights reserved.
//

import Foundation
import CoreMedia

protocol VideoPlaying {
    var isPlaying: Bool { get }
    var duration: CMTime? { get }

    func play()
    func pause()
    func seek(to: Float64, completion: @escaping (Bool) -> Void)
}

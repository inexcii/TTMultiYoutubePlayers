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

class UserDefaultsStore {

    static let instance = UserDefaults.standard

    #if DEBUG
    /// - Attention: use only for debug
    static func clearAll() {
        let appDomain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
    }
    #endif

    static var youtubeEntities: [YoutubeEntity] {
        get {
            let key = UserDefaultsKey.playedYoutubeEntity
            if let storedDatas = instance.object(forKey: key) as? [Data] {
                return storedDatas.map { try! PropertyListDecoder().decode(YoutubeEntity.self, from: $0) }
            } else {
                return [YoutubeEntity]()
            }
        }

        set {
            let key = UserDefaultsKey.playedYoutubeEntity
            instance.set(newValue.map { try! PropertyListEncoder().encode($0) }, forKey: key)
            instance.synchronize()
        }
    }
}

struct UserDefaultsKey {
    static let playedYoutubeEntity = "playedYoutubeEntity"
}

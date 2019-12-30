//
//  Utility.swift
//  TTMultiYoutubePlayers
//
//  Created by Yuan Zhou on 2019/10/19.
//  Copyright © 2019 GEN SHU. All rights reserved.
//

import UIKit

/// Print out debug message during development
///
/// - Parameters:
///   - message: message to print out
///   - filename: source file name(e.g. VideoPlayer.swift)
///   - function: function name where the message located(e.g. loadValuesInAsset(_:completion:) )
///   - line: line number(e.g. 109)
func DLog(_ message: String, filename: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
    NSLog("[%@:%ld] %@ - %@", (filename as NSString).lastPathComponent, line, function, message)
    #endif
}

class Utility {
    
    static func calculateAngle(from begin: CGPoint, to end: CGPoint) -> Double {
        let angle = atan2(Double(abs(end.y - begin.y)), Double(abs(end.x - begin.x)))
        let piAngle = angle * (180.0/Double.pi)
        let digit2Angle = Double(round(piAngle * 100) / 100)
        
        return digit2Angle
    }

    static func removeTimer(_ timer: inout Timer?) {
        if let aTimer = timer {
            aTimer.invalidate()
            timer = nil
        }
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

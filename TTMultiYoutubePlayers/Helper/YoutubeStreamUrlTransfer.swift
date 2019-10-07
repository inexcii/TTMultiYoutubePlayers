//
//  YoutubeStreamUrlTransfer.swift
//  TTMultiYoutubePlayers
//
//  Created by Yuan Zhou on 2019/10/07.
//  Copyright © 2019 GEN SHU. All rights reserved.
//

import Foundation
import XCDYouTubeKit

class YoutubeStreamUrlTransfer {
    
    let videoId: String
    
    init(videoId: String) {
        self.videoId = videoId
    }
    
    func transfer(completion: @escaping (URL?) -> Void) {
        XCDYouTubeClient.default().getVideoWithIdentifier(videoId) { (video, error) in
            if let error = error {
                print("error: \(error)")
                completion(nil)
            } else if let urls = video?.streamURLs {
                if let url = urls[XCDYouTubeVideoQuality.medium360.rawValue]{
                    completion(url)
                } else {
                    // Transfer to streams other than '.medium360', if necessary.
                    print("no medium360 resolution, need to try others")
                    completion(nil)
                }
            } else {
                print("video object has no available streaming urls")
                completion(nil)
            }
        }
    }
}

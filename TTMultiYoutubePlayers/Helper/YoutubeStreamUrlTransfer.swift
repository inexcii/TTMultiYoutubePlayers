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
    
    func transfer(completion: @escaping (Bool, URL?) -> Void) {
        XCDYouTubeClient.default().getVideoWithIdentifier(videoId) { (video, error) in
            if let error = error {
                DLog("error: \(error)")
                completion(false, nil)
                return
            }

            guard let video = video else { completion(false, nil); return }

            DLog("video duration of XCDYouTubeVideo: \(video.duration)")

            let (isLive, url) = self.extractUrlFromStreamURLs(video.streamURLs)
            completion(isLive, url ?? video.streamURL ?? nil)
        }
    }
}

// MARK: - Private
extension YoutubeStreamUrlTransfer {
    /// Extract a usable streaming URL for video playing from various URLs
    /// and determing whether the URL is using for HTTP Live Streaming(HLS) video.
    /// - Parameter urls: The quality of videos as key and various streaming URLs as value.
    /// - Returns: Whether the stream URL is a HTTP Live Streaming video and its URL.
    private func extractUrlFromStreamURLs(_ urls: [AnyHashable: URL]) -> (Bool, URL?) {
        if let url = urls[XCDYouTubeVideoQuality.medium360.rawValue]
            ?? urls[XCDYouTubeVideoQuality.small240.rawValue]
            ?? urls[XCDYouTubeVideoQuality.HD720.rawValue] {
            // extract three common kind of qualities ordered as: medium360 -> small240 -> HD720
            return (false, url)
        } else if let url = urls[XCDYouTubeVideoQualityHTTPLiveStreaming] {
            // HLS
            return (true, url)
        } else {
            DLog("WARNING! no common qualities or HTTP Live Streaming URL found, get first usable URL if possible")
            return (false, urls.values.first ?? nil)
        }
    }
}

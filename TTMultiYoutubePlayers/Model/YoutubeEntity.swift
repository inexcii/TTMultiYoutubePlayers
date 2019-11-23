//
//  YoutubeEntity.swift
//  TTMultiYoutubePlayers
//
//  Created by Yuan Zhou on 2019/11/23.
//  Copyright © 2019 GEN SHU. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST

struct YoutubeEntity: Codable {

    let videoId: String
    let title: String?
    let thumbnailImageUrl: URL?

    init?(searchResult: GTLRYouTube_SearchResult) {
        guard let videoId = searchResult.identifier?.videoId else {
            return nil
        }

        self.videoId = videoId
        self.title = searchResult.snippet?.title

        if let urlString = searchResult.snippet?.thumbnails?.medium?.url,
            let url = URL(string: urlString) {
            self.thumbnailImageUrl = url
        } else {
            self.thumbnailImageUrl = nil
        }
    }
}

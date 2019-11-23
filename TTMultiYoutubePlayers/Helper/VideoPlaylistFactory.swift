//
//  VideoPlaylistFactory.swift
//  TTMultiYoutubePlayers
//
//  Created by Yuan Zhou on 2019/10/07.
//  Copyright © 2019 GEN SHU. All rights reserved.
//

import RxSwift
import GoogleAPIClientForREST

class VideoPlaylistFactory {
    let result = BehaviorSubject<[YoutubeEntity]>(value: [])
    
    func search(keyword: String? = "バイク", maxResult: UInt = 50) {
        let query = GTLRYouTubeQuery_SearchList.query(withPart: "snippet")
        query.q = keyword
        query.type = "video"
        query.maxResults = maxResult
        
        let service = GTLRYouTubeService()
        service.apiKey = Constants.API.accessKey
        service.executeQuery(query) { (_ , object, error) in
            if error != nil {
                self.result.onNext([])
                return
            }
            guard let response = object as? GTLRYouTube_SearchListResponse,
                let playlist = response.items else {
                    self.result.onNext([])
                    return
            }
            self.result.onNext(playlist.compactMap { YoutubeEntity(searchResult: $0) })
        }
    }
}

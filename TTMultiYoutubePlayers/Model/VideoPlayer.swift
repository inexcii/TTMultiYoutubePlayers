//
//  VideoPlayer.swift
//  TTMultiYoutubePlayers
//
//  Created by Yuan Zhou on 2019/10/09.
//  Copyright © 2019 GEN SHU. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleAPIClientForREST

class VideoPlayer {
    
    var buttonPlay: UIButton!

    var entity: GTLRYouTube_SearchResult? {
        didSet {
            updatePlayer()
        }
    }
    var player = AVQueuePlayer()
    
    // MARK: - Life Cycle
    
    init(container: AVPlayerView) {
        let layer = container.layer as! AVPlayerLayer
        layer.player = player
    }
    
    // MARK: - Internal
    
    func connectUIs(buttonPlay: UIButton) {
        self.buttonPlay = buttonPlay
    }
    
    func setupUIs() {
        buttonPlay.setTitle(Constants.Title.Button.play, for: .normal)
    }
    
    func handleTapAction() {
        if player.rate > 0.0 {
            player.pause()
            buttonPlay.setTitle(Constants.Title.Button.play, for: .normal)
        } else {
            player.play()
            buttonPlay.setTitle(Constants.Title.Button.pause, for: .normal)
        }
    }
    
    // MARK: - Private
    
    private func updatePlayer() {
        if let videoId = entity?.identifier?.videoId {
            let transfer = YoutubeStreamUrlTransfer(videoId: videoId)
            transfer.transfer { (url) in
                if let url = url {
                    self.replaceAsset(with: url)
                }
            }
        }
    }
    
    private func replaceAsset(with url: URL) {
        player.removeAllItems()
        NSLog("asset begins")
        
        let asset = AVURLAsset(url: url)
        NSLog("asset finshed setup")
        loadValuesInAsset(asset) {
            let item = AVPlayerItem(asset: asset)
            self.player.insert(item, after: nil)
        }
    }
    
    private func loadValuesInAsset(_ asset: AVAsset, completion: @escaping () -> Void) {
        let keyPlayable = "playable"
        let keyDuration = "duration"
        let keys = [keyPlayable, keyDuration]
        asset.loadValuesAsynchronously(forKeys: keys) {
            var error: NSError? = nil
            for key in keys {
                let status = asset.statusOfValue(forKey: key, error: &error)
                switch status {
                case .loaded:
                    if key == keyPlayable {
                        NSLog("playable key finished loading")
                    } else if key == keyDuration {
                        NSLog("asset finished loading with duration: \(asset.duration.toDisplay())")
                    } else {
                        print("else to be loaded")
                    }
                case .failed:
                    print("fails to load \(key) with error:\(error)")
                case .cancelled:
                    print("fails to load \(key) due to cancelled operation")
                default:
                    print("fails to load \(key) by other reasons")
                }
            }
            completion()
        }
    }
}

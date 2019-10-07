//
//  ViewController.swift
//  TTMultiYoutubePlayers
//
//  Created by Yuan Zhou on 2019/10/06.
//  Copyright © 2019 GEN SHU. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleAPIClientForREST

class VideoPlayController: UIViewController {
    
    @IBOutlet weak var videoContainer1: AVPlayerView!
    @IBOutlet weak var videoContainer2: AVPlayerView!
    @IBOutlet weak var buttonPlay1: UIButton!
    @IBOutlet weak var buttonPlay2: UIButton!
    @IBOutlet weak var buttonSource1: UIButton!
    @IBOutlet weak var buttonSource2: UIButton!
    
    var player1 = AVQueuePlayer()
    var player2 = AVQueuePlayer()
    var videoEntity1: GTLRYouTube_SearchResult?
    var videoEntity2: GTLRYouTube_SearchResult?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonPlay1.setTitle(Constants.Title.Button.play, for: .normal)
        buttonPlay2.setTitle(Constants.Title.Button.play, for: .normal)
        
        insertVideoPlayer(player1, in: videoContainer1)
        insertVideoPlayer(player2, in: videoContainer2)
    }

    // MARK: - IBActions
    
    @IBAction func play1ButtonTapped(_ sender: Any) {
        if player1.rate > 0.0 {
            player1.pause()
            buttonPlay1.setTitle(Constants.Title.Button.play, for: .normal)
        } else {
            player1.play()
            buttonPlay1.setTitle(Constants.Title.Button.pause, for: .normal)
        }
    }
    
    @IBAction func play2ButtonTapped(_ sender: Any) {
        if player2.rate > 0.0 {
            player2.pause()
            buttonPlay2.setTitle(Constants.Title.Button.play, for: .normal)
        } else {
            player2.play()
            buttonPlay2.setTitle(Constants.Title.Button.pause, for: .normal)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            print("segue's identifier is not set")
            return
        }
        switch identifier {
        case "VideoPlaytoVideoSearch":
            guard let source = segue.source as? VideoPlayController,
                let destination = segue.destination as? VideoSearchViewController,
                let button = sender as? UIButton else {
                    print("source/destination ViewController is invalid, or sender is not a UIButton object")
                    return
            }
            
            destination.delegate = source
            destination.sourceButton = button
            
        default:
            print("identifier:\(identifier) is not recognized")
        }
    }
    
    // MARK: - Private
    
    private func insertVideoPlayer(_ player: AVQueuePlayer, in container: AVPlayerView) {
        let layer = container.layer as! AVPlayerLayer
        layer.player = player
    }
    
    private func replaceVideoEntity(_ entity: GTLRYouTube_SearchResult, in player: AVQueuePlayer) {
        if let videoId = entity.identifier?.videoId {
            let transfer = YoutubeStreamUrlTransfer(videoId: videoId)
            transfer.transfer { (url) in
                if let url = url {
                    self.replaceVideo(in: player, with: url)
                }
            }
        }
    }
    
    private func replaceVideo(in player: AVQueuePlayer, with url: URL) {
        player.removeAllItems()
        let item = AVPlayerItem(url: url)
        player.insert(item, after: nil)
    }
}

// MARK: - VideoSearchViewControllerDelegate

extension VideoPlayController: VideoSearchViewControllerDelegate {
    
    func didChooseVideo(_ entity: GTLRYouTube_SearchResult, source button: UIButton?) {
        guard let button = button else {
            print("source button is nil or unknown")
            return
        }
        
        switch button {
        case buttonSource1:
            videoEntity1 = entity
            replaceVideoEntity(entity, in: player1)
        case buttonSource2:
            videoEntity2 = entity
            replaceVideoEntity(entity, in: player2)
            
        default:
            print("got some button not belongs to this ViewController")
        }
    }
}


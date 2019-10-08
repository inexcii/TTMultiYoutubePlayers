//
//  ViewController.swift
//  TTMultiYoutubePlayers
//
//  Created by Yuan Zhou on 2019/10/06.
//  Copyright © 2019 GEN SHU. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST

class VideoPlayController: UIViewController {
    
    @IBOutlet weak var videoContainer1: AVPlayerView!
    @IBOutlet weak var videoContainer2: AVPlayerView!
    @IBOutlet weak var buttonPlay1: UIButton!
    @IBOutlet weak var buttonPlay2: UIButton!
    @IBOutlet weak var buttonSource1: UIButton!
    @IBOutlet weak var buttonSource2: UIButton!
    
    var videoPlayer1: VideoPlayer!
    var videoPlayer2: VideoPlayer!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoPlayer1 = VideoPlayer(container: videoContainer1)
        videoPlayer2 = VideoPlayer(container: videoContainer2)
        
        videoPlayer1.connectUIs(buttonPlay: buttonPlay1)
        videoPlayer1.setupUIs()
        videoPlayer2.connectUIs(buttonPlay: buttonPlay2)
        videoPlayer2.setupUIs()
    }

    // MARK: - IBActions
    
    @IBAction func play1ButtonTapped(_ sender: Any) {
        videoPlayer1.handleTapAction()
    }
    
    @IBAction func play2ButtonTapped(_ sender: Any) {
        videoPlayer2.handleTapAction()
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
            videoPlayer1.entity = entity
        case buttonSource2:
            videoPlayer2.entity = entity
        default:
            print("got some button not belongs to this ViewController")
        }
    }
}


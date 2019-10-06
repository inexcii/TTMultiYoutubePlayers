//
//  ViewController.swift
//  TTMultiYoutubePlayers
//
//  Created by Yuan Zhou on 2019/10/06.
//  Copyright © 2019 GEN SHU. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPlayController: UIViewController {
    
    @IBOutlet weak var videoContainer1: UIView!
    @IBOutlet weak var videoContainer2: UIView!
    @IBOutlet weak var buttonPlay1: UIButton!
    @IBOutlet weak var buttonPlay2: UIButton!
    
    var player1 = AVQueuePlayer()
    var player2 = AVQueuePlayer()
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonPlay1.setTitle(Constants.Title.Button.play, for: .normal)
        buttonPlay2.setTitle(Constants.Title.Button.play, for: .normal)
        
        insertVideoLayer(AVPlayerLayer(player: player1), in: videoContainer1)
        insertVideoLayer(AVPlayerLayer(player: player2), in: videoContainer2)
        
    }

    // MARK: IBActions
    @IBAction func source1ButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func source2ButtonTapped(_ sender: Any) {
        
    }
    
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
    
    // MARK: Private
    private func insertVideoLayer(_ layer: AVPlayerLayer, in view: UIView) {
        layer.frame = view.bounds
        layer.videoGravity = .resizeAspect
        view.layer.addSublayer(layer)
    }
}


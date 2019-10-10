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
    
    // UIs
    var buttonPlay: UIButton!
    var buttonSound: UIButton!
    var labelCurrentTime: UILabel!
    var labelDuration: UILabel!
    var seekBar: UISlider!

    var entity: GTLRYouTube_SearchResult? {
        didSet {
            resetPlayer()
        }
    }
    var player = AVQueuePlayer()
    var timeObserverToken: Any?
    
    // Status Control
    var isSeekBarBeingTouched = false
    
    // MARK: - Life Cycle
    
    init(container: AVPlayerView) {
        let layer = container.layer as! AVPlayerLayer
        layer.player = player
    }
    
    // MARK: - Internal
    
    func connectUIs(buttonPlay: UIButton, buttonSound: UIButton, labelCurrentTime: UILabel, labelDuration: UILabel, seekBar: UISlider) {
        self.buttonPlay = buttonPlay
        self.buttonSound = buttonSound
        self.labelCurrentTime = labelCurrentTime
        self.labelDuration = labelDuration
        self.seekBar = seekBar
    }
    
    func setupUIs() {
        buttonPlay.setTitle(Constants.Title.Button.play, for: .normal)
        buttonSound.setTitle(Constants.Title.Button.soundOn, for: .normal)
    }
    
    func handlePlayPauseTapAction() {
        if player.rate > 0.0 {
            player.pause()
            buttonPlay.setTitle(Constants.Title.Button.play, for: .normal)
        } else {
            player.play()
            buttonPlay.setTitle(Constants.Title.Button.pause, for: .normal)
        }
    }
    
    func handleSoundButtonTapped() {
        player.volume = player.volume == 0.0 ? 1.0: 0.0
        buttonSound.setTitle(player.volume == 0.0 ? Constants.Title.Button.soundOff: Constants.Title.Button.soundOn,
                             for: .normal)
    }
    
    func handleSeekBarChangeValue() {
        guard let duration = player.currentItem?.duration else { return }
        let seekTime = getSeekTime(seekBar.value, by: duration)
        labelCurrentTime.text = seekTime.toDisplay()
    }
    
    func handleSeekBarTouchUp() {
        isSeekBarBeingTouched = false
        
        guard let duration = player.currentItem?.duration else { return }
        let seekTime = getSeekTime(seekBar.value, by: duration)
        player.seek(to: seekTime, completionHandler: { (_) in })
    }
    
    func handleSeekBarTouchDown() {
        isSeekBarBeingTouched = true
    }
    
    // MARK: - Private
    
    private func resetPlayer() {
        // remove all the old things
        player.removeAllItems()
        if let token = timeObserverToken {
            player.removeTimeObserver(token)
            timeObserverToken = nil
        }
        
        // set new things
        if let videoId = entity?.identifier?.videoId {
            let transfer = YoutubeStreamUrlTransfer(videoId: videoId)
            transfer.transfer { (url) in
                if let url = url {
                    // setup AVAsset
                    let asset = AVURLAsset(url: url)
                    self.loadValuesInAsset(asset) {
                        // setup AVPlayer
                        let item = AVPlayerItem(asset: asset)
                        self.player.insert(item, after: nil)
                        self.addPeriodicTimeObserver()
                    }
                }
            }
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
                        DispatchQueue.main.async {
                            self.labelDuration.text = asset.duration.toDisplay()
                        }
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
    
    private func addPeriodicTimeObserver() {
        // Invoke callback every 0.5 second
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            // Do not update some UI when user is trying to seek video.
            if !(self?.isSeekBarBeingTouched ?? true) {
                self?.labelCurrentTime.text = time.toDisplay()
                self?.setSeekBarValue(progress: time)
            }
        }
    }
    
    private func setSeekBarValue(progress: CMTime) {
        guard let duration = player.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        let progressSeconds = CMTimeGetSeconds(progress)
        seekBar.value = Float(progressSeconds / totalSeconds)
    }
    
    private func getSeekTime(_ seekBarValue: Float, by duration: CMTime) -> CMTime {
        let totalSeconds = CMTimeGetSeconds(duration)
        let value = Float64(seekBarValue) * totalSeconds
        return CMTime(value: Int64(value), timescale: 1)
    }
}
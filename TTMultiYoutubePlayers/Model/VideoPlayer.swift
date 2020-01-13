//
//  VideoPlayer.swift
//  TTMultiYoutubePlayers
//
//  Created by Yuan Zhou on 2019/10/09.
//  Copyright © 2019 GEN SHU. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPlayer {

    enum SeekType {
        case rewind, fastForward
    }

    /// calculate as 30fps as default if the video frame rate cannot be retrieved
    private static let oneFrameDefault: Float64 = 0.033

    private var videoFrameRate: Float?
    private var oneFrame: Float64 {
        if let frameRate = videoFrameRate {
            return Float64(1.0 / frameRate)
        } else {
            return VideoPlayer.oneFrameDefault
        }
    }

    // UIs
    var labelCurrentTime: UILabel!
    var labelDuration: UILabel!
    var seekBar: UISlider!

    var entity: YoutubeEntity? {
        didSet {
            resetPlayer()
        }
    }
    var player = AVQueuePlayer()
    var timeObserverToken: Any?
    
    // Status Control
    var isSeekBarBeingTouched = false
    
    // MARK: - Life Cycle

    init(videoView: VideoView, videoId: String? = nil, currentTimeLabel: UILabel, durationLabel: UILabel, seekBar: UISlider) {
        connectUIs(currentTimeLabel: currentTimeLabel,
                   durationLabel: durationLabel,
                   seekBar: seekBar)

        let layer = videoView.playerView.layer as! AVPlayerLayer
        layer.player = player
        if let videoId = videoId {
            setupPlayer(by: videoId)
        }
    }
    /* specific to VideoView
    private func connectUIs(with videoView: VideoView) {
        self.labelCurrentTime = videoView.labelCurrentTime
        self.labelDuration = videoView.labelDuration
        self.seekBar = videoView.seekbar

        videoView.delegate = self
    }
     */
    private func connectUIs(currentTimeLabel: UILabel, durationLabel: UILabel, seekBar: UISlider) {
        self.labelCurrentTime = currentTimeLabel
        self.labelDuration = durationLabel
        self.seekBar = seekBar
    }

    // MARK: - Internal

    func handleOneFrameSeek(_ type: SeekType) {
        guard let duration = player.currentItem?.duration else { return }

        let seekValue = currentSeekValue(seekBar.value, duration: duration)
        var toBeSeekValue: Float64
        switch type {
        case .rewind:
            toBeSeekValue = seekValue - oneFrame
        case .fastForward:
            toBeSeekValue = seekValue + oneFrame
        }
        let time = seekTime(toBeSeekValue)
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { _ in
            // update seekbar's value
            self.seekBar.value = Float(toBeSeekValue / CMTimeGetSeconds(duration))
        }
    }

    func handlePlayPause(_ button: UIButton) {
        if isPlaying {
            player.pause()
            button.setBackgroundImage(R.image.play(), for: .normal)
        } else {
            player.play()
            button.setBackgroundImage(R.image.pause(), for: .normal)
        }
    }

    func handleMute(_ button: UIButton) {
        player.volume = player.volume == 0.0 ? 1.0: 0.0
        button.setBackgroundImage(player.volume == 0.0 ? R.image.mute(): R.image.unmute(),
                                  for: .normal)
    }

    func handleSeekbarValueChanged(_ seekbar: UISlider) {
        guard let duration = player.currentItem?.duration else { return }
        let seekTime = getSeekTime(seekbar.value, by: duration)
        labelCurrentTime.text = seekTime.toDisplay()
    }
    func handleSeekbarTouchup(_ seekbar: UISlider) {
        guard let duration = player.currentItem?.duration else { return }
        let seekTime = getSeekTime(seekbar.value, by: duration)

        player.seek(to: seekTime, completionHandler: { (_) in
            self.isSeekBarBeingTouched = false
        })
    }
    func handleSeekbarTouchDown(_ seekbar: UISlider) {
        isSeekBarBeingTouched = true
    }
    
    // MARK: - Private
    
    private func setupPlayer(by videoId: String) {
        let transfer = YoutubeStreamUrlTransfer(videoId: videoId)
        transfer.transfer { (url) in
            if let url = url {
                // setup AVAsset
                let asset = AVURLAsset(url: url)
                self.videoFrameRate = asset.frameRate
                self.loadValuesInAsset(asset) {
                    // setup AVPlayer
                    let item = AVPlayerItem(asset: asset)
                    self.player.insert(item, after: nil)
                    self.addPeriodicTimeObserver()
                }
            }
        }
    }

    private func resetPlayer() {
        // remove all the old things
        player.removeAllItems()
        if let token = timeObserverToken {
            player.removeTimeObserver(token)
            timeObserverToken = nil
        }

        // set new things
        if let videoId = entity?.videoId {
            setupPlayer(by: videoId)
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
                        DLog("playable key finished loading")
                    } else if key == keyDuration {
                        DispatchQueue.main.async {
                            self.labelDuration.text = asset.duration.toDisplay()
                        }
                    } else {
                        print("else to be loaded")
                    }
                case .failed:
                    print("fails to load \(key) with error:\(String(describing: error))")
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
        // Invoke callback every x second
        let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
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
        let value = currentSeekValue(seekBarValue, duration: duration)
        return seekTime(value)
    }

    private func currentSeekValue(_ seekBarValue: Float, duration: CMTime) -> Float64 {
        let totalSeconds = CMTimeGetSeconds(duration)
        let value = Float64(seekBarValue) * totalSeconds
        return value
    }

    private func seekTime(_ value: Float64) -> CMTime {
        // specified to 3-digit point
        return CMTime(value: Int64(value * 1000), timescale: 1000)
    }
}

// MARK: - Delegate

/* specific to VideoView
// MARK: VideoViewDelegate
extension VideoPlayer : VideoViewDelegate {

    func didTapPlayButton(_ button: UIButton) {
        handlePlayPause(button)
    }

    func didTapMuteButton(_ button: UIButton) {
        handleMute(button)
    }

    func didChangedSeekbarValue(_ seekbar: UISlider) {
        handleSeekbarValueChanged(seekbar)
    }
    func didTouchUpSeekbar(_ seekbar: UISlider) {
        handleSeekbarTouchup(seekbar)
    }
    func didTouchDownSeekbar(_ seekbar: UISlider) {
        handleSeekbarTouchDown(seekbar)
    }

    func didTapOneFrameRewindButton(_ button: UIButton) {
        handleOneFrameSeek(.rewind)
    }
    func didTapOneFrameForwardButton(_ button: UIButton) {
        handleOneFrameSeek(.fastForward)
    }
}
 */

// MARK: Status

extension VideoPlayer {

    var isPlaying: Bool {
        return player.rate > 0.0
    }
}

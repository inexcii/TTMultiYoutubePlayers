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

    var videoId: String? {
        didSet {
            if let videoId = videoId {
                setupPlayer(by: videoId)
            }
        }
    }
    var videoUrl: URL? {
        didSet {
            if let url = videoUrl {
                setupPlayer(by: url)
            }
        }
    }

    var player = AVQueuePlayer()
    var looper: AVPlayerLooper?
    var timeObserverToken: Any?
    
    // Status Control
    var isSeekBarBeingTouched = false

    /// UI setup handler for rewind and forward buttons
    /// - Parameter: Bool whether the video is HTTP Live Streaming or not
    var rewindForwardSetupHandler: ((Bool) -> ())? = nil
    
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
        guard let duration = duration else { return }

        let seekValue = currentSeekValue(seekBar.value, duration: duration)
        var toBeSeekValue: Float64
        switch type {
        case .rewind:
            toBeSeekValue = seekValue - oneFrame
        case .fastForward:
            toBeSeekValue = seekValue + oneFrame
        }
        seek(to: toBeSeekValue) { _ in
            // update seekbar's value
            self.seekBar.value = Float(toBeSeekValue / CMTimeGetSeconds(duration))
        }
    }

    func handlePlayPause(_ button: UIButton) {
        if isPlaying {
            pause()
            button.setBackgroundImage(R.image.play(), for: .normal)
        } else {
            play()
            button.setBackgroundImage(R.image.pause(), for: .normal)
        }
    }

    func handleVolumeChange(_ volume: Float) {
        player.volume = volume
    }

    func handleSeekbarValueChanged(_ seekbar: UISlider) {
        guard let duration = duration else { return }
        let seekTime = getSeekTime(seekbar.value, by: duration)
        labelCurrentTime.text = seekTime.toDisplay()
    }
    func handleSeekbarTouchup(_ seekbar: UISlider) {
        guard let duration = duration else { return }
        let time = currentSeekValue(seekbar.value, duration: duration)
        seek(to: time) { _ in
            self.isSeekBarBeingTouched = false
        }
    }
    func handleSeekbarTouchDown(_ seekbar: UISlider) {
        isSeekBarBeingTouched = true
    }

    // MARK: - Private
    
    private func setupPlayer(by videoId: String) {
        let transfer = YoutubeStreamUrlTransfer(videoId: videoId)
        transfer.transfer { [weak self] isLive, url in
            guard let url = url else {
                print("warning, url not exists")
                return
            }
            guard let self = self else { return }
            self.setupPlayer(by: url, isLive: isLive)
            self.rewindForwardSetupHandler?(isLive)
        }
    }

    private func setupPlayer(by url: URL, isLive: Bool = false) {
        resetPlayer(isLive: isLive)

        DLog("video url: \(url)")

        // setup AVAsset
        let asset = AVURLAsset(url: url)
        self.videoFrameRate = asset.frameRate
        self.loadValuesInAsset(asset) { [weak self] in
            guard let self = self else { return }
            // setup AVPlayer
            let item = AVPlayerItem(asset: asset)
            self.player.insert(item, after: nil)

            if isLive == false {
                self.looper = AVPlayerLooper(player: self.player, templateItem: item)
                self.addPeriodicTimeObserver()
            }
        }
    }

    private func resetPlayer(isLive: Bool = false) {
        // remove all the old things
        player.removeAllItems()
        if let token = timeObserverToken {
            player.removeTimeObserver(token)
            timeObserverToken = nil
        }

        // reset UI
        seekBar.isEnabled = isLive == false
        labelDuration.isHidden = isLive
        labelCurrentTime.isHidden = isLive
        rewindForwardSetupHandler?(isLive)
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
                        DLog("video duration of AVAsset: \(CMTimeGetSeconds(asset.duration))")
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
        guard let duration = duration else { return }
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

// MARK: - VideoPlaying

extension VideoPlayer: VideoPlaying {
    var duration: CMTime? {
        return player.currentItem?.duration
    }

    var isPlaying: Bool {
        return player.rate > 0.0
    }

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }

    func seek(to time: Float64, completion: @escaping (Bool) -> Void) {
        let cmTime = seekTime(time)
        player.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: completion)
    }
}

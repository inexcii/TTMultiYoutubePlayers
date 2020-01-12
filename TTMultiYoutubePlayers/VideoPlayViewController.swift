//
//  VideoPlayViewController.swift
//  TTMultiYoutubePlayers
//
//  Created by Yuan Zhou on 2019/11/28.
//  Copyright © 2019 GEN SHU. All rights reserved.
//

import UIKit

final class VideoPlayViewController: UIViewController {

    @IBOutlet weak var videoView1: VideoView!
    @IBOutlet weak var videoView2: VideoView!
    @IBOutlet weak var currentTime1Label: UILabel!
    @IBOutlet weak var duration1Label: UILabel!
    @IBOutlet weak var seekBar1: UISlider!
    @IBOutlet weak var currentTime2Label: UILabel!
    @IBOutlet weak var duration2Label: UILabel!
    @IBOutlet weak var seekBar2: UISlider!

    @IBOutlet private weak var commonPlayButton: UIButton!

    var videoPlayer1: VideoPlayer!
    var videoPlayer2: VideoPlayer!

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(handleNavigation(_:)),
                                               name: VideoView.didTapSourceButtonNotification, object: nil)

        videoPlayer1 = VideoPlayer(videoView: videoView1,
                                   videoId: Constants.sampleVideoId1,
                                   currentTimeLabel: currentTime1Label,
                                   durationLabel: duration1Label,
                                   seekBar: seekBar1)
        videoPlayer2 = VideoPlayer(videoView: videoView2,
                                   videoId: Constants.sampleVideoId2,
                                   currentTimeLabel: currentTime2Label,
                                   durationLabel: duration2Label,
                                   seekBar: seekBar2)
    }

    @IBAction func commonPlayButtonTapped(_ sender: Any) {
        videoPlayer1.handlePlayPause(videoView1.buttonPlay)
        videoPlayer2.handlePlayPause(videoView2.buttonPlay)

        if videoPlayer1.isPlaying {
            commonPlayButton.setBackgroundImage(R.image.common_pause(), for: .normal)
        } else {
            commonPlayButton.setBackgroundImage(R.image.common_play(), for: .normal)
        }
    }

    @IBAction func play1ButtonTapped(_ sender: UIButton) {
        videoPlayer1.handlePlayPause(sender)
    }
    @IBAction func play2ButtonTapped(_ sender: UIButton) {
        videoPlayer2.handlePlayPause(sender)
    }
    @IBAction func oneFrameForward1ButtonTapped(_ sender: UIButton) {
        videoPlayer1.handleOneFrameSeek(.fastForward)
    }
    @IBAction func oneFrameRewind1ButtonTapped(_ sender: UIButton) {
        videoPlayer1.handleOneFrameSeek(.rewind)
    }
    @IBAction func oneFrameForward2ButtonTapped(_ sender: UIButton) {
        videoPlayer2.handleOneFrameSeek(.fastForward)
    }
    @IBAction func oneFrameRewind2ButtonTapped(_ sender: UIButton) {
        videoPlayer2.handleOneFrameSeek(.rewind)
    }
    @IBAction func mute1ButtonTapped(_ sender: UIButton) {
        videoPlayer1.handleMute(sender)
    }
    @IBAction func mute2ButtonTapped(_ sender: UIButton) {
        videoPlayer2.handleMute(sender)
    }
    @IBAction func slider1TouchUp(_ sender: UISlider) {
        videoPlayer1.handleSeekbarTouchup(sender)
    }
    @IBAction func slider1TouchDown(_ sender: UISlider) {
        videoPlayer1.handleSeekbarTouchDown(sender)
    }
    @IBAction func slider1ValueChanged(_ sender: UISlider) {
        videoPlayer1.handleSeekbarValueChanged(sender)
    }
    @IBAction func slider2TouchUp(_ sender: UISlider) {
        videoPlayer2.handleSeekbarTouchup(sender)
    }
    @IBAction func slider2TouchDown(_ sender: UISlider) {
        videoPlayer2.handleSeekbarTouchDown(sender)
    }
    @IBAction func slider2ValueChanged(_ sender: UISlider) {
        videoPlayer2.handleSeekbarValueChanged(sender)
    }

    @IBAction func search1ButtonTapped(_ sender: UIButton) {
        videoView1.videoSourceButtonTapped(sender)
    }
    @IBAction func search2ButtonTapped(_ sender: UIButton) {
        videoView2.videoSourceButtonTapped(sender)
    }

    @objc private func handleNavigation(_ notification: Notification) {
        let videoSearchVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VideoSearchViewController") as! VideoSearchViewController
        videoSearchVC.delegate = self
        videoSearchVC.source = notification.object
        self.present(videoSearchVC, animated: true) {
            DLog("finish presenting search VC")
        }
    }
}

// MARK: - VideoSearchViewControllerDelegate

extension VideoPlayViewController: VideoSearchViewControllerDelegate {

    func didChooseVideo(_ entity: YoutubeEntity, source: Any?) {
        guard let source = source as? VideoView else { return }
        if source == videoView1 {
            videoPlayer1.entity = entity
        } else if source == videoView2 {
            videoPlayer2.entity = entity
        }
    }
}

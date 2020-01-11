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

        videoPlayer1 = VideoPlayer(videoView: videoView1, videoId: Constants.sampleVideoId1)
        videoPlayer2 = VideoPlayer(videoView: videoView2, videoId: Constants.sampleVideoId2)
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
        videoPlayer1.didTapPlayButton(sender)
    }
    @IBAction func play2ButtonTapped(_ sender: UIButton) {
        videoPlayer2.didTapPlayButton(sender)
    }
    @IBAction func oneFrameForward1ButtonTapped(_ sender: UIButton) {
        videoPlayer1.didTapOneFrameForwardButton(sender)
    }
    @IBAction func oneFrameRewind1ButtonTapped(_ sender: UIButton) {
        videoPlayer1.didTapOneFrameRewindButton(sender)
    }
    @IBAction func oneFrameForward2ButtonTapped(_ sender: UIButton) {
        videoPlayer2.didTapOneFrameForwardButton(sender)
    }
    @IBAction func oneFrameRewind2ButtonTapped(_ sender: UIButton) {
        videoPlayer2.didTapOneFrameRewindButton(sender)
    }
    @IBAction func mute1ButtonTapped(_ sender: UIButton) {
        videoPlayer1.didTapMuteButton(sender)
    }
    @IBAction func mute2ButtonTapped(_ sender: UIButton) {
        videoPlayer2.didTapMuteButton(sender)
    }

    @IBAction func search1ButtonTapped(_ sender: UIButton) {
        videoView1.videoSourceButtonTapped(sender)
    }
    @IBAction func search2ButtonTapped(_ sender: UIButton) {
        videoView2.videoSourceButtonTapped(sender)
    }
    @IBAction func slider1TouchUp(_ sender: UISlider) {
        videoView1.seekbarTouchUp(sender)
    }
    @IBAction func slider1TouchDown(_ sender: UISlider) {
        videoView1.seekbarTouchDown(sender)
    }
    @IBAction func slider1ValueChanged(_ sender: UISlider) {
        videoView1.seekbarValueChanged(sender)
    }
    @IBAction func slider2TouchUp(_ sender: UISlider) {
        videoView2.seekbarTouchUp(sender)
    }
    @IBAction func slider2TouchDown(_ sender: UISlider) {
        videoView2.seekbarTouchDown(sender)
    }
    @IBAction func slider2ValueChanged(_ sender: UISlider) {
        videoView2.seekbarValueChanged(sender)
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

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
    @IBOutlet weak var rewind1Button: UIButton!
    @IBOutlet weak var forward1Button: UIButton!
    @IBOutlet weak var currentTime2Label: UILabel!
    @IBOutlet weak var duration2Label: UILabel!
    @IBOutlet weak var seekBar2: UISlider!
    @IBOutlet weak var play2Button: UIButton!
    @IBOutlet weak var rewind2Button: UIButton!
    @IBOutlet weak var forward2Button: UIButton!

    @IBOutlet private weak var commonPlayButton: UIButton!

    var videoPlayer1: VideoPlayer!
    var videoPlayer2: VideoPlayer!

    private var picker: VideoPicker?
    private var isSyncEnabled: Bool = false {
        didSet {
            play2Button.isEnabled = !isSyncEnabled
            rewind2Button.isEnabled = !isSyncEnabled && !isLiveVideoInPlayer2
            forward2Button.isEnabled = !isSyncEnabled && !isLiveVideoInPlayer2
            seekBar2.isEnabled = !isSyncEnabled && !isLiveVideoInPlayer2

            if isSyncEnabled {
                // sync Play2 button with Play1 button's status
                if (videoPlayer1.isPlaying != videoPlayer2.isPlaying) {
                    videoPlayer2.handlePlayPause(play2Button)
                }
            }
        }
    }

    private var isLiveVideoInPlayer2: Bool = false {
        didSet {
            rewind2Button.isEnabled = !isLiveVideoInPlayer2 && !isSyncEnabled
            forward2Button.isEnabled = !isLiveVideoInPlayer2 && !isSyncEnabled
            seekBar2.isEnabled = !isLiveVideoInPlayer2 && !isSyncEnabled
        }
    }

    private var longPressTimer: Timer?

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

        let forward1LongPress = UILongPressGestureRecognizer(target: self, action: #selector(forward1LongPress(_:)))
        forward1Button.addGestureRecognizer(forward1LongPress)
        let forward2LongPress = UILongPressGestureRecognizer(target: self, action: #selector(forward2LongPress(_:)))
        forward2Button.addGestureRecognizer(forward2LongPress)
        let rewind1LongPress = UILongPressGestureRecognizer(target: self, action: #selector(rewind1LongPress(_:)))
        rewind1Button.addGestureRecognizer(rewind1LongPress)
        let rewind2LongPress = UILongPressGestureRecognizer(target: self, action: #selector(rewind2LongPress(_:)))
        rewind2Button.addGestureRecognizer(rewind2LongPress)

        videoPlayer1.rewindForwardSetupHandler = { [weak self] isLive in
            self?.rewind1Button.isEnabled = isLive == false
            self?.forward1Button.isEnabled = isLive == false
        }
        videoPlayer2.rewindForwardSetupHandler = { [weak self] isLive in
            self?.isLiveVideoInPlayer2 = isLive
        }
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
        if isSyncEnabled {
            videoPlayer2.handlePlayPause(play2Button)
        }
    }
    @IBAction func play2ButtonTapped(_ sender: UIButton) {
        videoPlayer2.handlePlayPause(sender)
    }
    @IBAction func oneFrameForward1ButtonTapped(_ sender: UIButton) {
        videoPlayer1.handleOneFrameSeek(.fastForward)
        if isSyncEnabled {
            videoPlayer2.handleOneFrameSeek(.fastForward)
        }
    }
    @IBAction func oneFrameRewind1ButtonTapped(_ sender: UIButton) {
        videoPlayer1.handleOneFrameSeek(.rewind)
        if isSyncEnabled {
            videoPlayer2.handleOneFrameSeek(.rewind)
        }
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
        if isSyncEnabled {
            videoPlayer2.handleSeekbarTouchup(sender)
        }
    }
    @IBAction func slider1TouchDown(_ sender: UISlider) {
        videoPlayer1.handleSeekbarTouchDown(sender)
        if isSyncEnabled {
            videoPlayer2.handleSeekbarTouchDown(sender)
        }
    }
    @IBAction func slider1ValueChanged(_ sender: UISlider) {
        videoPlayer1.handleSeekbarValueChanged(sender)
        if isSyncEnabled {
            videoPlayer2.handleSeekbarValueChanged(sender)
        }
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
    @IBAction func syncSwitchValueChanged(_ sender: UISwitch) {
        isSyncEnabled = sender.isOn
    }

    @objc private func handleNavigation(_ notification: Notification) {

        let optionMenu = UIAlertController(title: nil, message: "Search Video In", preferredStyle: .actionSheet)
        let youtubeSearch = UIAlertAction(title: "YouTube", style: .default) { action in
            let videoSearchVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VideoSearchViewController") as! VideoSearchViewController
            videoSearchVC.delegate = self
            videoSearchVC.source = notification.object
            self.present(videoSearchVC, animated: true) {
            }
        }
        let photoAlbum = UIAlertAction(title: "Photo Album", style: .default) { action in
            if let picker = VideoPicker(src: .photoLibrary) {
                picker.delegate = self
                picker.source = notification.object
                self.present(picker.controller, animated: true) {
                }
                self.picker = picker
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        optionMenu.addAction(youtubeSearch)
        optionMenu.addAction(photoAlbum)
        optionMenu.addAction(cancel)
        self.present(optionMenu, animated: true, completion: nil)
    }
}

// MARK: - VideoSearchViewControllerDelegate

extension VideoPlayViewController: VideoSearchViewControllerDelegate {

    func didChooseVideo(_ entity: YoutubeEntity, source: Any?) {
        guard let source = source as? VideoView else { return }
        if source == videoView1 {
            videoPlayer1.videoId = entity.videoId
        } else if source == videoView2 {
            videoPlayer2.videoId = entity.videoId
        }
    }
}

// MARK: - VideoPickerDelegate

extension VideoPlayViewController: VideoPickerDelegate {
    func didRetrieveVideoUrl(_ controller: UIImagePickerController, _ url: URL, _ source: Any?) {
        guard let source = source as? VideoView else { return }
        if source == videoView1 {
            videoPlayer1.videoUrl = url
        } else if source == videoView2 {
            videoPlayer2.videoUrl = url
        }
        controller.dismiss(animated: true) {
            self.picker = nil
        }
    }

    func didCancelPicking(_ controller: UIImagePickerController) {
        controller.dismiss(animated: true) {
            self.picker = nil
        }
    }
}

// MARK: - 1-Frame buttons Long-press Gesture

extension VideoPlayViewController {

    @objc private func forward1LongPress(_ sender: UILongPressGestureRecognizer? = nil) {
        guard let longPress = sender else { return }

        switch longPress.state {
        case .began:
            initLongPressGestureTimer { _ in
                self.oneFrameForward1ButtonTapped(UIButton())
            }
        case .ended:
            longPressTimer?.invalidate()
        default: break
        }
    }

    @objc private func forward2LongPress(_ sender: UILongPressGestureRecognizer? = nil) {
        guard let longPress = sender else { return }

        switch longPress.state {
        case .began:
            initLongPressGestureTimer { _ in
                self.oneFrameForward2ButtonTapped(UIButton())
            }
        case .ended:
            longPressTimer?.invalidate()
        default: break
        }
    }

    @objc private func rewind1LongPress(_ sender: UILongPressGestureRecognizer? = nil) {
        guard let longPress = sender else { return }

        switch longPress.state {
        case .began:
            initLongPressGestureTimer { _ in
                self.oneFrameRewind1ButtonTapped(UIButton())
            }
        case .ended:
            longPressTimer?.invalidate()
        default: break
        }
    }

    @objc private func rewind2LongPress(_ sender: UILongPressGestureRecognizer? = nil) {
        guard let longPress = sender else { return }

        switch longPress.state {
        case .began:
            initLongPressGestureTimer { _ in
                self.oneFrameRewind2ButtonTapped(UIButton())
            }
        case .ended:
            longPressTimer?.invalidate()
        default: break
        }
    }

    private func initLongPressGestureTimer(_ action: @escaping ((Timer) -> Void)) {
        self.longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.175, repeats: true, block: action)
    }
}

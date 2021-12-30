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
    @IBOutlet weak var commonControlView: UIView!
    @IBOutlet weak var currentTime1Label: UILabel!
    @IBOutlet weak var duration1Label: UILabel!
    @IBOutlet weak var seekBar1: UISlider!
    @IBOutlet weak var volume1Button: UIButton!
    @IBOutlet weak var rewind1Button: UIButton!
    @IBOutlet weak var forward1Button: UIButton!
    @IBOutlet weak var currentTime2Label: UILabel!
    @IBOutlet weak var duration2Label: UILabel!
    @IBOutlet weak var seekBar2: UISlider!
    @IBOutlet weak var play2Button: UIButton!
    @IBOutlet weak var volume2Button: UIButton!
    @IBOutlet weak var rewind2Button: UIButton!
    @IBOutlet weak var forward2Button: UIButton!

    @IBOutlet private weak var commonPlayButton: UIButton!

    private lazy var volumeChangeView1: VolumeChangeView = {
        let viewHeight = 32.0
        let view = VolumeChangeView()

        // round corner
        view.layer.masksToBounds = true
        view.layer.cornerRadius = viewHeight / 2.0

        view.isHidden = true
        view.delegate = self

        self.commonControlView.insertSubview(view, aboveSubview: self.volume1Button)

        view.translatesAutoresizingMaskIntoConstraints = false
        view.leftAnchor.constraint(equalTo: volume1Button.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: volume1Button.centerYAnchor, constant: -(viewHeight / 2.0)).isActive = true
        view.widthAnchor.constraint(equalToConstant: 150).isActive = true
        view.heightAnchor.constraint(equalToConstant: viewHeight).isActive = true

        return view
    }()
    private lazy var volumeChangeView2: VolumeChangeView = {
        let viewHeight = 32.0
        let view = VolumeChangeView()

        // round corner
        view.layer.masksToBounds = true
        view.layer.cornerRadius = viewHeight / 2.0

        view.isHidden = true
        view.delegate = self

        self.commonControlView.insertSubview(view, aboveSubview: self.volume2Button)

        view.translatesAutoresizingMaskIntoConstraints = false
        view.leftAnchor.constraint(equalTo: volume2Button.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: volume2Button.centerYAnchor, constant: -(viewHeight / 2.0)).isActive = true
        view.widthAnchor.constraint(equalToConstant: 150).isActive = true
        view.heightAnchor.constraint(equalToConstant: viewHeight).isActive = true

        return view
    }()

    private lazy var tappingView: TappingView = {
        let view = TappingView()

        view.isHidden = true
        view.delegate = self

        self.commonControlView.insertSubview(view, belowSubview: volume1Button)

        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: self.commonControlView.topAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: self.commonControlView.rightAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.commonControlView.bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: self.commonControlView.leftAnchor).isActive = true

        return view
    }()

    private var videoPlayer1: VideoPlayer!
    private var videoPlayer2: VideoPlayer!

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

    private var player1Volume: Float = 0.0 {
        didSet {
            videoPlayer1.handleVolumeChange(player1Volume)

            if oldValue == 0.0 && player1Volume > 0.0 {
                volume1Button.setBackgroundImage(R.image.unmute(), for: .normal)
            }
            if oldValue > 0.0 && player1Volume == 0.0 {
                volume1Button.setBackgroundImage(R.image.mute(), for: .normal)
            }
        }
    }
    private var player2Volume: Float = 0.0 {
        didSet {
            videoPlayer2.handleVolumeChange(player2Volume)

            if oldValue == 0.0 && player2Volume > 0.0 {
                volume2Button.setBackgroundImage(R.image.unmute(), for: .normal)
            }
            if oldValue > 0.0 && player2Volume == 0.0 {
                volume2Button.setBackgroundImage(R.image.mute(), for: .normal)
            }
        }
    }

    private var longPressTimer: Timer?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Life Cycle

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

    // MARK: - IBActions

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
        if shouldSyncSameActionInPlayer2 {
            videoPlayer2.handleOneFrameSeek(.fastForward)
        }
    }
    @IBAction func oneFrameRewind1ButtonTapped(_ sender: UIButton) {
        videoPlayer1.handleOneFrameSeek(.rewind)
        if shouldSyncSameActionInPlayer2 {
            videoPlayer2.handleOneFrameSeek(.rewind)
        }
    }
    @IBAction func oneFrameForward2ButtonTapped(_ sender: UIButton) {
        videoPlayer2.handleOneFrameSeek(.fastForward)
    }
    @IBAction func oneFrameRewind2ButtonTapped(_ sender: UIButton) {
        videoPlayer2.handleOneFrameSeek(.rewind)
    }
    @IBAction func volume1ButtonTapped(_ sender: UIButton) {
        toggleVolumeChangeView1()
    }
    @IBAction func volume2ButtonTapped(_ sender: UIButton) {
        toggleVolumeChangeView2()
    }
    @IBAction func slider1TouchUp(_ sender: UISlider) {
        videoPlayer1.handleSeekbarTouchup(sender)
        if shouldSyncSameActionInPlayer2 {
            videoPlayer2.handleSeekbarTouchup(sender)
        }
    }
    @IBAction func slider1TouchDown(_ sender: UISlider) {
        videoPlayer1.handleSeekbarTouchDown(sender)
        if shouldSyncSameActionInPlayer2 {
            videoPlayer2.handleSeekbarTouchDown(sender)
        }
    }
    @IBAction func slider1ValueChanged(_ sender: UISlider) {
        videoPlayer1.handleSeekbarValueChanged(sender)
        if shouldSyncSameActionInPlayer2 {
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
        let optionMenu = UIAlertController(
            title: nil,
            message: R.string.localizable.videoplayvcSearchActionMessage(),
            preferredStyle: .actionSheet
        )

        let youtubeSearch = UIAlertAction(
            title: R.string.localizable.videoplayvcSearchActionOptionYoutubePublic(),
            style: .default
        ) { _ in
            let videoSearchVC = R.storyboard.main.videoSearchViewController()!
            videoSearchVC.delegate = self
            videoSearchVC.source = notification.object
            self.present(videoSearchVC, animated: true) {
            }
        }
        let photoAlbum = UIAlertAction(
            title: R.string.localizable.videoplayvcSearchActionOptionPhotoalbum(),
            style: .default
        ) { _ in
            if let picker = VideoPicker(src: .photoLibrary) {
                picker.delegate = self
                picker.source = notification.object
                self.present(picker.controller, animated: true) {
                }
                self.picker = picker
            }
        }
        let cancel = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel, handler: nil)
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

extension VideoPlayViewController: VolumeChangeViewDelegate {
    func didChangeVolume(in view: VolumeChangeView, volume: Float) {
        if view == volumeChangeView1 {
            player1Volume = volume
        } else if view == volumeChangeView2 {
            player2Volume = volume
        }
    }
}

// MARK: - TappingViewDelegate

extension VideoPlayViewController: TappingViewDelegate {
    func didTapTappingView() {
        toggleVolumeChangeView1(isHidden: true)
        toggleVolumeChangeView2(isHidden: true)
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

// MARK: - Private
extension VideoPlayViewController {
    private var shouldSyncSameActionInPlayer2: Bool {
        return isSyncEnabled && isLiveVideoInPlayer2 == false
    }

    private func toggleVolumeChangeView1(isHidden: Bool? = nil) {
        guard let isHidden = isHidden else {
            let isVolumeChangeViewHidden = volumeChangeView1.isHidden
            volumeChangeView1.isHidden = !isVolumeChangeViewHidden
            tappingView.isHidden = !isVolumeChangeViewHidden && volumeChangeView2.isHidden
            return
        }

        volumeChangeView1.isHidden = isHidden
        tappingView.isHidden = isHidden && volumeChangeView2.isHidden
    }
    private func toggleVolumeChangeView2(isHidden: Bool? = nil) {
        guard let isHidden = isHidden else {
            let isVolumeChangeViewHidden = volumeChangeView2.isHidden
            volumeChangeView2.isHidden = !isVolumeChangeViewHidden
            tappingView.isHidden = !isVolumeChangeViewHidden && volumeChangeView1.isHidden
            return
        }

        volumeChangeView2.isHidden = isHidden
        tappingView.isHidden = isHidden && volumeChangeView1.isHidden
    }
}

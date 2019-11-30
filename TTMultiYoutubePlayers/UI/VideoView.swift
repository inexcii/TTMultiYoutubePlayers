//
//  VideoView.swift
//  TTMultiYoutubePlayers
//
//  Created by Yuan Zhou on 2019/11/25.
//  Copyright © 2019 GEN SHU. All rights reserved.
//

import UIKit

protocol VideoViewDelegate: class {
    func didTapPlayButton(_ button: UIButton)
    func didTapMuteButton(_ button: UIButton)
    func didChangedSeekbarValue(_ seekbar: UISlider)
    func didTouchUpSeekbar(_ seekbar: UISlider)
    func didTouchDownSeekbar(_ seekbar: UISlider)
    func didTapOneFrameRewindButton(_ button: UIButton)
    func didTapOneFrameForwardButton(_ button: UIButton)
}

class VideoView: UIView {

    static let didTapSourceButtonNotification = Notification.Name.init("VideoViewDidTapSourceButtonNotification")

    weak var delegate: VideoViewDelegate?

    @IBOutlet private(set) weak var playerView: AVPlayerView!
    @IBOutlet private(set) weak var labelCurrentTime: UILabel!
    @IBOutlet private(set) weak var labelDuration: UILabel!
    @IBOutlet private(set) weak var seekbar: UISlider!

    @IBOutlet private weak var paintView: PaintView!
    @IBOutlet private weak var controlPanel: UIView!
    @IBOutlet private weak var buttonPlay: UIButton!
    @IBOutlet private weak var buttonMute: UIButton!

    @IBOutlet private weak var labelAngle: UILabel!

    // MARK: - Override

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        completeInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        completeInit()
    }

    func completeInit() {
        loadNib()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        buttonPlay.setTitle(Constants.Title.Button.play, for: .normal)
        buttonMute.setTitle(Constants.Title.Button.soundOn, for: .normal)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapOnPlayerView(_:)))
        playerView.addGestureRecognizer(tap)

        paintView.delegate = self
    }

    // MARK: - Gestures & IBActions

    @objc private func handleTapOnPlayerView(_ sender: UITapGestureRecognizer? = nil) {
        self.controlPanel.isHidden = !self.controlPanel.isHidden
    }

    @IBAction func playButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapPlayButton(sender)
    }
    @IBAction func muteButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapMuteButton(sender)
    }
    @IBAction func seekbarValueChanged(_ sender: UISlider) {
        self.delegate?.didChangedSeekbarValue(sender)
    }
    @IBAction func seekbarTouchUp(_ sender: UISlider) {
        self.delegate?.didTouchUpSeekbar(sender)
    }
    @IBAction func seekbarTouchDown(_ sender: UISlider) {
        self.delegate?.didTouchDownSeekbar(sender)
    }
    @IBAction func oneFrameRewindButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapOneFrameRewindButton(sender)
    }
    @IBAction func oneFrameForwardButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapOneFrameForwardButton(sender)
    }

    @IBAction func videoSourceButtonTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: VideoView.didTapSourceButtonNotification, object: self, userInfo: nil)
    }

    @IBAction func undoPaintButtonTapped(_ sender: UIButton) {
        paintView.undo()
        labelAngle.text = "0.0"
    }
}

// MARK: - Delegate

// MARK: PaintViewDelegate

extension VideoView: PaintViewDelegate {

    func didGenerateLineAngle(angle: Double, view: PaintView) {
        labelAngle.text = String(angle)
    }

}

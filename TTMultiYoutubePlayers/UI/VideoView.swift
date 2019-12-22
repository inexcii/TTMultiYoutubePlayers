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

    @IBOutlet private weak var doubleTapToMinusOneFrameArea: UIView!
    @IBOutlet private weak var doubleTapToPlayArea: UIView!
    @IBOutlet private weak var doubleTapToPlusOneFrameArea: UIView!

    private var singleTapGesture: UITapGestureRecognizer!
    private var doubleTapGesture: UITapGestureRecognizer!

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

        buttonPlay.setBackgroundImage(R.image.play(), for: .normal)
        buttonMute.setBackgroundImage(R.image.unmute(), for: .normal)
        labelAngle.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)

        initTapGestures()
        playerView.addGestureRecognizer(singleTapGesture)

        paintView.delegate = self
    }

    // MARK: - IBActions

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

    @IBAction func videoSourceButtonTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: VideoView.didTapSourceButtonNotification, object: self, userInfo: nil)
    }

    @IBAction func undoPaintButtonTapped(_ sender: UIButton) {
        paintView.undo()
        labelAngle.text = "0.0"
    }
}

// MARK: - Gestures

extension VideoView {

    @objc private func handleSingleTapOnPlayerView(_ sender: UITapGestureRecognizer? = nil) {

        // when control panel is hidden: enable double-tap gesture
        // when control panel shows up: disable double-tap gesture
        if controlPanel.alpha > 0 {
            UIView.animate(withDuration: 0.3, animations: {
                self.controlPanel.alpha = 0.0
            }) { finished in
                // prevent to add double tap gesture twice
                if self.doubleTapGesture.view == nil {
                    self.playerView.addGestureRecognizer(self.doubleTapGesture)
                }
            }
        } else {
            if let view = doubleTapGesture.view {
                view.removeGestureRecognizer(doubleTapGesture)
            }
            controlPanel.alpha = 1.0
        }
    }

    @objc private func handleDoubleTapOnPlayerView(_ sender: UITapGestureRecognizer? = nil) {
        guard let doubleTap = sender, controlPanel.alpha == 0.0 else { return }

        let point = doubleTap.location(in: playerView)
        if doubleTapToPlayArea.frame.contains(point) {
            self.delegate?.didTapPlayButton(self.buttonPlay)
        } else if doubleTapToMinusOneFrameArea.frame.contains(point) {
            self.delegate?.didTapOneFrameRewindButton(UIButton())
        } else if doubleTapToPlusOneFrameArea.frame.contains(point) {
            self.delegate?.didTapOneFrameForwardButton(UIButton())
        }
    }
}

// MARK: - Delegate

// MARK: PaintViewDelegate

extension VideoView: PaintViewDelegate {

    func didGenerateLineAngle(angle: Double, view: PaintView) {
        labelAngle.text = String(angle)
    }

}

// MARK: UIGestureRecognizerDelegate

extension VideoView: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view is UISlider) {
            return false
        } else {
            return true
        }
    }
}

// MARK: - Private

extension VideoView {

    func initTapGestures() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapOnPlayerView(_:)))
        doubleTap.numberOfTapsRequired = 2
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTapOnPlayerView(_:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.require(toFail: doubleTap)

        singleTapGesture = singleTap
        doubleTapGesture = doubleTap

        singleTapGesture.delegate = self
    }
}

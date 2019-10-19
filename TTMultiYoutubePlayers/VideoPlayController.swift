//
//  ViewController.swift
//  TTMultiYoutubePlayers
//
//  Created by Yuan Zhou on 2019/10/06.
//  Copyright © 2019 GEN SHU. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST

class VideoPlayController: UIViewController {
    
    @IBOutlet weak var videoContainer1: AVPlayerView!
    @IBOutlet weak var videoContainer2: AVPlayerView!
    @IBOutlet weak var paintView1: PaintView!
    @IBOutlet weak var paintView2: PaintView!
    @IBOutlet weak var buttonPlay1: UIButton!
    @IBOutlet weak var buttonPlay2: UIButton!
    @IBOutlet weak var buttonSource1: UIButton!
    @IBOutlet weak var buttonSource2: UIButton!
    @IBOutlet weak var buttonUndo1: UIButton!
    @IBOutlet weak var buttonUndo2: UIButton!
    @IBOutlet weak var buttonSound1: UIButton!
    @IBOutlet weak var buttonSound2: UIButton!
    @IBOutlet weak var labelCurrentTime1: UILabel!
    @IBOutlet weak var labelDuration1: UILabel!
    @IBOutlet weak var labelCurrentTime2: UILabel!
    @IBOutlet weak var labelDuration2: UILabel!
    @IBOutlet weak var labelAngle1: UILabel!
    @IBOutlet weak var labelAngle2: UILabel!
    @IBOutlet weak var seekBar1: UISlider!
    @IBOutlet weak var seekBar2: UISlider!
    
    var videoPlayer1: VideoPlayer!
    var videoPlayer2: VideoPlayer!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoPlayer1 = VideoPlayer(container: videoContainer1, videoId: Constants.sampleVideoId1)
        videoPlayer2 = VideoPlayer(container: videoContainer2, videoId: Constants.sampleVideoId2)
        
        videoPlayer1.connectUIs(buttonPlay: buttonPlay1, buttonSound: buttonSound1, labelCurrentTime: labelCurrentTime1, labelDuration: labelDuration1, seekBar: seekBar1)
        videoPlayer1.setupUIs()
        videoPlayer2.connectUIs(buttonPlay: buttonPlay2, buttonSound: buttonSound2, labelCurrentTime: labelCurrentTime2, labelDuration: labelDuration2, seekBar: seekBar2)
        videoPlayer2.setupUIs()
        
        paintView1.delegate = self
        paintView2.delegate = self
    }

    // MARK: - IBActions
    
    @IBAction func playPauseButtonTapped(_ sender: Any) {
        if let button = sender as? UIButton {
            if button == buttonPlay1 {
                videoPlayer1.handlePlayPauseTapAction()
            } else if button == buttonPlay2 {
                videoPlayer2.handlePlayPauseTapAction()
            }
        }
    }
    @IBAction func soundButtonTapped(_ sender: Any) {
        if let button = sender as? UIButton {
            if button == buttonSound1 {
                videoPlayer1.handleSoundButtonTapped()
            } else if button == buttonSound2 {
                videoPlayer2.handleSoundButtonTapped()
            }
        }
    }
    @IBAction func undoButtonTapped(_ sender: Any) {
        if let button = sender as? UIButton {
            if button == buttonUndo1 {
                paintView1.undo()
                labelAngle1.text = "0.0"
            } else if button == buttonUndo2 {
                paintView2.undo()
                labelAngle2.text = "0.0"
            }
        }
    }
    
    @IBAction func seekBarValueChanged(_ sender: Any) {
        if let slider = sender as? UISlider {
            if slider == seekBar1 {
                videoPlayer1.handleSeekBarChangeValue()
            } else if slider == seekBar2 {
                videoPlayer2.handleSeekBarChangeValue()
            }
        }
    }
    @IBAction func seekBarTouchUp(_ sender: Any) {
        if let slider = sender as? UISlider {
            if slider == seekBar1 {
                videoPlayer1.handleSeekBarTouchUp()
            } else if slider == seekBar2 {
                videoPlayer2.handleSeekBarTouchUp()
            }
        }
    }
    @IBAction func seekBarTouchDown(_ sender: Any) {
        if let slider = sender as? UISlider {
            if slider == seekBar1 {
                videoPlayer1.handleSeekBarTouchDown()
            } else if slider == seekBar2 {
                videoPlayer2.handleSeekBarTouchDown()
            }
        }
    }
    
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            print("segue's identifier is not set")
            return
        }
        switch identifier {
        case "VideoPlaytoVideoSearch":
            guard let source = segue.source as? VideoPlayController,
                let destination = segue.destination as? VideoSearchViewController,
                let button = sender as? UIButton else {
                    print("source/destination ViewController is invalid, or sender is not a UIButton object")
                    return
            }
            
            destination.delegate = source
            destination.sourceButton = button
            
        default:
            print("identifier:\(identifier) is not recognized")
        }
    }
    
    // MARK: - Private
    
}

// MARK: - VideoSearchViewControllerDelegate

extension VideoPlayController: VideoSearchViewControllerDelegate {
    
    func didChooseVideo(_ entity: GTLRYouTube_SearchResult, source button: UIButton?) {
        guard let button = button else {
            print("source button is nil or unknown")
            return
        }
        
        switch button {
        case buttonSource1:
            videoPlayer1.entity = entity
        case buttonSource2:
            videoPlayer2.entity = entity
        default:
            print("got some button not belongs to this ViewController")
        }
    }
}

extension VideoPlayController: PaintViewDelegate {
    
    func didGenerateLineAngle(angle: Double, view: PaintView) {
        if view == paintView1 {
            labelAngle1.text = String(angle)
        } else if view == paintView2 {
            labelAngle2.text = String(angle)
        }
    }
}


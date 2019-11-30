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

    @objc private func handleNavigation(_ notification: Notification) {
        let videoSearchVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VideoSearchViewController") as! VideoSearchViewController
        videoSearchVC.delegate = self
        videoSearchVC.source = notification.object
        self.present(videoSearchVC, animated: true) {
            print("finish presenting search VC")
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

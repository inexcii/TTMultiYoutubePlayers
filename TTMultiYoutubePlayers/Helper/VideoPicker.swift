//
//  VideoPicker.swift
//  TTMultiYoutubePlayers
//
//  Created by Yuan Zhou on 2020/01/14.
//  Copyright © 2020 GEN SHU. All rights reserved.
//

import UIKit
import PhotosUI

protocol VideoPickerDelegate: AnyObject {
    func didRetrieveVideoUrl(_ controller: UIViewController, _ url: URL, _ source: Any?)
    func didCancelPicking(_ controller: UIViewController)
}

/**
 A class for picking the video from the Camera Roll

 For accessing the video's url, using the delegate method `didRetrieveVideoUrl(controller:url:)`
 */
class VideoPicker: NSObject {
    let controller: PHPickerViewController

    weak var delegate: VideoPickerDelegate?
    var source: Any?

    deinit {
        print(self, #function)
    }

    override init() {
        var config = PHPickerConfiguration()
        config.filter = .videos
        config.preferredAssetRepresentationMode = .current

        controller = PHPickerViewController(configuration: config)

        super.init()

        controller.delegate = self
    }
}

extension VideoPicker: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard let result = results.first else {
            self.delegate?.didCancelPicking(picker)
            return
        }

        let movie = UTType.movie.identifier
        let provider = result.itemProvider
        if provider.hasItemConformingToTypeIdentifier(movie) {
            provider.loadFileRepresentation(forTypeIdentifier: movie) { [weak self] url, error in
                guard let self = self, let url = url else { return }
                DLog("camera roll video url: \(url)")
                DispatchQueue.main.sync {
                    self.delegate?.didRetrieveVideoUrl(picker, url, self.source)
                }
            }
        }
    }
}

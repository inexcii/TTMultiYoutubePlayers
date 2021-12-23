//
//  VideoPicker.swift
//  TTMultiYoutubePlayers
//
//  Created by Yuan Zhou on 2020/01/14.
//  Copyright © 2020 GEN SHU. All rights reserved.
//

import UIKit

import MobileCoreServices

protocol VideoPickerDelegate: AnyObject {
    func didRetrieveVideoUrl(_ controller: UIImagePickerController, _ url: URL, _ source: Any?)
    func didCancelPicking(_ controller: UIImagePickerController)
}

/**
 A class for picking the video from the Camera Roll

 For accessing the video's url, using the delegate method `didRetrieveVideoUrl(controller:url:)`
 */
class VideoPicker: NSObject {

    let controller = UIImagePickerController()

    weak var delegate: VideoPickerDelegate?
    var source: Any?

    deinit {
        print("deinit VideoPicker")
    }

    init?(src: UIImagePickerController.SourceType) {
        super.init()

        guard UIImagePickerController.isSourceTypeAvailable(src) else {
            print("source type not available")
            return nil
        }

        controller.sourceType = src
        controller.mediaTypes = [(kUTTypeMovie as String)]
        controller.delegate = self
    }
}

extension VideoPicker: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard info[.mediaType] as? String == (kUTTypeMovie as String) else {
            fatalError("not a movie")
        }
        guard let url = info[.mediaURL] as? URL else {
            fatalError("not a media URL")
        }

        self.delegate?.didRetrieveVideoUrl(picker, url, source)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.delegate?.didCancelPicking(picker)
    }
}

extension VideoPicker: UINavigationControllerDelegate {}

//
//  YouTubeUnlistedInputViewController.swift
//  TTMultiYoutubePlayers
//
//  Created by Yuan Zhou on 2022/01/01.
//  Copyright © 2022 GEN SHU. All rights reserved.
//

import UIKit

protocol YouTubeUnlistedInputViewControllerDelegate: AnyObject {
    func didTapOKButton(videoId: String, source: Any?)
}

class YouTubeUnlistedInputViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!

    var source: Any?
    weak var delegate: YouTubeUnlistedInputViewControllerDelegate?

    deinit {
        print(self, #function)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func okButtonTapped(_ sender: Any) {
        dismissWithCallingDelegate()
    }
}

extension YouTubeUnlistedInputViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        dismissWithCallingDelegate()

        return true
    }
}

extension YouTubeUnlistedInputViewController {
    private func dismissWithCallingDelegate() {
        self.delegate?.didTapOKButton(
            videoId: extractVideoIdFromUrl(textField.text),
            source: self.source
        )
        self.dismiss(animated: true, completion: nil)
    }

    private func extractVideoIdFromUrl(_ urlString: String?) -> String {
        return String(urlString?.split(separator: "/").last ?? "")
    }
}

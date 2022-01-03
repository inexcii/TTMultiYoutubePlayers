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
        guard let videoId = extractVideoIdFromUrl(textField.text),
              !videoId.isEmpty else {
                  let alert = UIAlertController(
                    title: nil,
                    message: R.string.localizable.youtubeunlistedinputvcErrorEmptyVideourlMessage(),
                    preferredStyle: .alert
                  )
                  alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                  self.present(alert, animated: true, completion: nil)
                  return
              }

        self.delegate?.didTapOKButton(videoId: videoId, source: self.source)
        self.dismiss(animated: true, completion: nil)
    }

    private func extractVideoIdFromUrl(_ urlString: String?) -> String? {
        guard let urlString = urlString,
              let videoId = urlString.split(separator: "/").last else { return nil }
        return String(videoId)
    }
}

//
//  VolumeChangeView.swift
//  TTMultiYoutubePlayers
//
//  Created by Yuan Zhou on 2021/12/28.
//  Copyright © 2021 GEN SHU. All rights reserved.
//

import UIKit

protocol VolumeChangeViewDelegate: AnyObject {
    func didChangeVolume(in view: VolumeChangeView, volume: Float)
}

class VolumeChangeView: UIView {
    @IBOutlet var content: UIView!
    @IBOutlet weak var slider: UISlider!

    weak var delegate: VolumeChangeViewDelegate?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }

    private func initSubviews() {
        let nib = UINib(nibName: "VolumeChangeView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        content.frame = bounds
        addSubview(content)
    }

    @IBAction func sliderValueChanged(_ sender: Any) {
        self.delegate?.didChangeVolume(in: self, volume: slider.value)
    }
}

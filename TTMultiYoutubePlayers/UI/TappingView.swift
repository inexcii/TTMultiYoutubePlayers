//
//  TappingView.swift
//  TTMultiYoutubePlayers
//
//  Created by Yuan Zhou on 2021/12/30.
//  Copyright © 2021 GEN SHU. All rights reserved.
//

import UIKit

protocol TappingViewDelegate: AnyObject {
    func didTapTappingView()
}

class TappingView: UIView {
    weak var delegate: TappingViewDelegate?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }

    private func initSubviews() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        self.addGestureRecognizer(tap)
    }

    @objc private func tapped(_ sender: UITapGestureRecognizer) {
        self.delegate?.didTapTappingView()
    }
}

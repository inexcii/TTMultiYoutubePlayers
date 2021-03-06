//
//  VideoSearchTableViewCell.swift
//  TTMultiYoutubePlayers
//
//  Created by Yuan Zhou on 2019/10/07.
//  Copyright © 2019 GEN SHU. All rights reserved.
//

import UIKit
import Nuke

class VideoSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(by entity: YoutubeEntity) {
        if let url = entity.thumbnailImageUrl {
            Nuke.loadImage(with: url, into: thumbnailImageView)
        }
        if let title = entity.title {
            self.titleLabel.text = title
        }
    }
}

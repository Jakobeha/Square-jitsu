//
// Created by Jakob Hain on 7/13/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import UIKit

class LevelItemCollectionViewCell: UICollectionViewCell {
    static let widthHeight: CGFloat = 128
    
    @IBOutlet private var label: UILabel! = nil
    @IBOutlet private var iconImageView: UIImageView! = nil

    var levelItem: LevelItem? = nil {
        didSet {
            label.text = levelItem?.label ?? LevelItem.loadingLabel
            iconImageView.image = levelItem?.icon ?? LevelItem.unknownIcon
        }
    }

    override var isHighlighted: Bool {
        didSet { backgroundImageView.isHidden = !isHighlighted }
    }

    override var isSelected: Bool {
        didSet { selectedBackgroundImageView.isHidden = !isSelected }
    }

    private var backgroundImageView: UIImageView {
        backgroundView! as! UIImageView
    }

    private var selectedBackgroundImageView: UIImageView {
        selectedBackgroundView! as! UIImageView
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        levelItem = nil
        isHighlighted = false
    }
}

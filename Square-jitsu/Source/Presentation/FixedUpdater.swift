//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class FixedUpdater {
    var onTick: (() -> ())? = nil
    var fixedDeltaTime: CGFloat = CGFloat.nan {
        didSet {
            if (fixedDeltaTime.isNaN) {
                fixedCurrentTime = TimeInterval.nan
            }
        }
    }
    private var fixedCurrentTime: TimeInterval = TimeInterval.nan

    init() {}

    func update(_ currentTime: TimeInterval) {
        if !fixedDeltaTime.isNaN {
            if fixedCurrentTime.isNaN {
                fixedCurrentTime = currentTime
            } else {
                while fixedCurrentTime < currentTime {
                    onTick?()
                    fixedCurrentTime += TimeInterval(fixedDeltaTime)
                }
            }
        }
    }
}

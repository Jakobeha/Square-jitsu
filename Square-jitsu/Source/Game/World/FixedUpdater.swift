//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class FixedUpdater {
    /// After enough fixed updates we just ignore the rest, because they would
    /// create lag and the player isn't getting anything out of slowing the game this much
    private static let maxFixedUpdatesBeforeWeIgnoreTheRest: Int = 5

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
                var numFixedUpdatesSoFar = 0
                while fixedCurrentTime < currentTime &&
                      numFixedUpdatesSoFar < FixedUpdater.maxFixedUpdatesBeforeWeIgnoreTheRest {
                    onTick?()
                    fixedCurrentTime += TimeInterval(fixedDeltaTime)
                    numFixedUpdatesSoFar += 1
                }
            }
        }
    }
}

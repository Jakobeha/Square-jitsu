//
// Created by Jakob Hain on 5/20/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Forwards touch events for a button control
class ButtonNode: ControlNode {
    override init(size: CGSize) {
        super.init(size: size)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented in ButtonNode")
    }
}

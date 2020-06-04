//
// Created by Jakob Hain on 6/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

enum Slope {
    case thisIsAPoint(this: CGPoint)
    case moreHorizontal(yDivX: CGFloat)
    case moreVertical(xDivY: CGFloat)
}
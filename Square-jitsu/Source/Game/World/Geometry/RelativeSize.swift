//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct RelativeSize: Equatable, Hashable {
    static let unit: RelativeSize = RelativeSize(width: 1, height: 1)
    
    static func ceil(_ cgSize: CGSize) -> RelativeSize {
        RelativeSize(width: Int(Foundation.ceil(cgSize.width)), height: Int(Foundation.ceil(cgSize.height)))
    }
    
    let width: Int
    let height: Int

    var toCgSize: CGSize {
        CGSize(width: width, height: height)
    }
}

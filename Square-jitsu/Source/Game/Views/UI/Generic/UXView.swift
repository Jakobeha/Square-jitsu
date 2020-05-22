//
// Created by Jakob Hain on 5/20/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

protocol UXView: View {
    var topLeft: CGPoint { get set }
    /// If either axis is infinity, that means we stretch as much as possible within the screen bounds
    var size: CGSize { get }
}

extension UXView {
    var bounds: CGRect { CGRect(origin: topLeft, size: size) }
}
//
// Created by Jakob Hain on 7/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class DimView: UXView {
    private static let dimOpacity: CGFloat = 0.5
    private static let dimColor: SKColor = SKColor(white: 0, alpha: dimOpacity)

    private let dimNode: SKSpriteNode = SKSpriteNode(texture: nil, color: DimView.dimColor, size: CGSize.zero)
    private var sceneSize: CGSize = CGSize.zero {
        didSet { dimNode.size = sceneSize }
    }

    var node: SKNode { dimNode }
    var size: CGSize { sceneSize }

    init() {
        dimNode.anchorPoint = UXSpriteAnchor
    }

    func set(sceneSize: CGSize) {
        self.sceneSize = sceneSize
    }
}
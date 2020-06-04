//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct LaserEntityViewTemplate: EntityViewTemplate, SingleSettingCodable {
    let color: SKColor
    let thickness: CGFloat

    func generateNode(entity: Entity) -> SKNode {
        assert(entity.next.lilC != nil, "laser entity view is only allowed on entities with line positions")

        let node = SKShapeNode(path: generatePath(entity: entity))
        configure(node: node, tileWidthHeight: entity.world!.settings.tileViewWidthHeight)

        return node
    }

    func generatePreviewNode(size: CGSize) -> SKNode {
        let previewLine = Line(start: CGPoint(x: size.width / 2, y: 0), end: CGPoint(x: size.width / 2, y: size.height))

        let node = SKShapeNode(path: CGPath.of(line: previewLine))
        configure(node: node, tileWidthHeight: size.minValue)

        return node
    }

    private func configure(node: SKShapeNode, tileWidthHeight: CGFloat) {
        node.strokeColor = color
        node.lineWidth = thickness * tileWidthHeight
    }

    func tick(entity: Entity, node: SKNode) {
        let node = node as! SKShapeNode

        node.path = generatePath(entity: entity)
    }

    private func generatePath(entity: Entity) -> CGPath {
        CGPath.of(line: entity.next.lilC!.position.scaleCoordsBy(scale: entity.world!.settings.tileViewWidthHeight))
    }

    // region encoding and decoding
    typealias AsSetting = StructSetting<LaserEntityViewTemplate>

    static func newSetting() -> StructSetting<LaserEntityViewTemplate> {
        StructSetting(requiredFields: [
            "color": ColorSetting(),
            "thickness": CGFloatRangeSetting(0...2)
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}

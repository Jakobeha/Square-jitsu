//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

final class LaserEntityViewTemplate: EmptyEntityViewTemplate, SingleSettingCodable {
    let color: SKColor
    let thickness: CGFloat

    init(color: SKColor, thickness: CGFloat) {
        self.color = color
        self.thickness = thickness
    }

    override func generateNode(entity: Entity) -> SKNode {
        guard entity.next.lilC != nil else {
            Logger.warnSettingsAreInvalid("laser entity view is only allowed on entities with line positions")
            return super.generateNode(entity: entity)
        }

        let node = SKShapeNode(path: generatePath(entity: entity))
        configure(node: node, tileWidthHeight: entity.world!.settings.tileViewWidthHeight)

        return node
    }

    override func generatePreviewNode(size: CGSize, settings: WorldSettings) -> SKNode {
        let previewLine = LineSegment(start: CGPoint(x: size.width / 2, y: 0), end: CGPoint(x: size.width / 2, y: size.height))

        let node = SKShapeNode(path: CGPath.of(line: previewLine))
        configure(node: node, tileWidthHeight: size.minValue)

        return node
    }

    private func configure(node: SKShapeNode, tileWidthHeight: CGFloat) {
        node.strokeColor = color
        node.lineWidth = thickness * tileWidthHeight
    }

    override func tick(entity: Entity, node: SKNode) {
        // Should be non-nil unless there are bad settings (and we warn if so)
        let node = node as? SKShapeNode
        node?.path = generatePath(entity: entity)
    }

    private func generatePath(entity: Entity) -> CGPath {
        CGPath.of(line: entity.world!.settings.convertTileToView(line: entity.next.lilC!.position))
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

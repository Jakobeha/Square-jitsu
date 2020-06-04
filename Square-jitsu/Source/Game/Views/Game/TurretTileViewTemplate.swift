//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct TurretTileViewTemplate: TileViewTemplate, SingleSettingCodable {
    let base: TileViewTemplate
    let turretTexture: SKTexture

    func generateNode(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType) -> SKNode {
        assert(tileType.bigType == .turret, "TurretTileViewTemplate is only allowed on turret tiles")

        let baseNode = base.generateNode(world: world, pos3D: pos3D, tileType: tileType)

        let turretBehavior = world.getBehaviorAt(pos3D: pos3D)! as! TurretBehavior

        let turretNode = SKSpriteNode(texture: turretTexture, size: CGSize.square(sideLength: world.settings.tileViewWidthHeight))
        baseNode.addChild(turretNode)

        updateFor(turretNode: turretNode, metadata: turretBehavior.metadata)
        turretBehavior.didChangeMetadata.subscribe(observer: turretNode, priority: .view) {
            self.updateFor(turretNode: turretNode, metadata: turretBehavior.metadata)
        }

        turretNode.isHidden = turretBehavior.spawned
        turretBehavior.didSpawn.subscribe(observer: turretNode, priority: .view) { entity in
            turretNode.isHidden = true
        }
        turretBehavior.didRevert.subscribe(observer: turretNode, priority: .view) {
            turretNode.isHidden = false
        }

        return baseNode
    }
    
    private func updateFor(turretNode: SKNode, metadata: TurretMetadata?) {
        if let metadata = metadata {
            turretNode.angle = metadata.initialTurretDirectionRelativeToAnchor
        }
    }

    func generatePreviewNode(size: CGSize) -> SKNode {
        // The turret entity will already be rendered on top of the preview,
        // so we don't need to add it here
        base.generatePreviewNode(size: size)
    }

    func didPlaceInParent(node: SKNode) {}

    func didRemoveFromParent(node: SKNode) {}

    // region encoding and decoding
    typealias AsSetting = StructSetting<TurretTileViewTemplate>

    static func newSetting() -> StructSetting<TurretTileViewTemplate> {
        StructSetting(requiredFields: [
            "base": DeferredSetting { TileViewTemplateSetting() },
            "turretTexture": TextureSetting()
        ], optionalFields: [:], allowedExtraFields: ["type"])
    }
    // endregion
}

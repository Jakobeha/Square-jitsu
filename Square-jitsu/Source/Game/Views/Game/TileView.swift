//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class TileView: OptionalNodeView {
    private static func generateNode(template: TileViewTemplate?, world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType, coordinates: TileViewCoordinates) -> SKNode? {
        let node = template?.generateNode(world: world, pos3D: pos3D, tileType: tileType)
        if let node = node {
            switch coordinates {
            case .chunk:
                // Uses chunk position because this node is a child of the chunk's node
                let chunkPos = pos3D.pos.chunkTilePos
                node.position = chunkPos.cgPoint * world.settings.tileViewWidthHeight
            case .world:
                node.position = pos3D.pos.cgPoint * world.settings.tileViewWidthHeight
            }
            node.zPosition = tileType.bigType.layer.zPosition
            if world.settings.rotateTileViewBasedOnOrientation[tileType] ?? false {
                node.angle = tileType.orientation.asSide.angle
            }
        }
        return node
    }

    private let world: ReadonlyWorld
    private let tileType: TileType
    private let template: TileViewTemplate?
    private let glossMaskNode: SKNode?
    private let glossMaskChild: SKNode?

    private var settings: WorldSettings { world.settings }

    init(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType, coordinates: TileViewCoordinates, glossMaskNode: SKNode?) {
        self.world = world
        self.tileType = tileType
        template = world.settings.tileViewTemplates[tileType]
        self.glossMaskNode = glossMaskNode
        glossMaskChild = glossMaskNode == nil || !world.settings.glossyTileViews.contains(tileType) ?
                nil :
                TileView.generateNode(template: template, world: world, pos3D: pos3D, tileType: tileType, coordinates: coordinates)
        super.init(node: TileView.generateNode(template: template, world: world, pos3D: pos3D, tileType: tileType, coordinates: coordinates))
    }

    override func placeIn(parent: SKNode) {
        super.placeIn(parent: parent)
        template?.didPlaceInParent(node: node!)

        if let glossMaskChild = glossMaskChild {
            // glossMaskNode is definitely not nil, otherwise we wouldn't create the child
            glossMaskNode!.addChild(glossMaskChild)
        }
    }

    override func removeFromParent() {
        glossMaskChild?.removeFromParent()

        if let fadeDuration = settings.tileViewFadeDurations[tileType] {
            node?.zPosition += TileType.fadingZPositionOffset
            node?.run(SKAction.fadeOut(withDuration: fadeDuration)) {
                super.removeFromParent()
                self.template?.didRemoveFromParent(node: self.node!)
            }
        } else {
            super.removeFromParent()
            template?.didRemoveFromParent(node: node!)
        }
    }
}

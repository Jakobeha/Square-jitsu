//
// Created by Jakob Hain on 5/5/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class TileView: OptionalNodeView {
    private static func generateNode(template: TileViewTemplate?, world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType, coordinates: TileViewCoordinates) -> SKNode? {
        let node = template?.generateNode(world: world, pos3D: pos3D, tileType: tileType)
        configure(node: node, world: world, pos3D: pos3D, tileType: tileType, coordinates: coordinates)
        return node
    }

    private static func generateGlossNode(template: TileViewTemplate?, world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType, coordinates: TileViewCoordinates) -> SKNode? {
        let node = template?.generateGlossNode(world: world, pos3D: pos3D, tileType: tileType)
        configure(node: node, world: world, pos3D: pos3D, tileType: tileType, coordinates: coordinates)
        return node
    }

    private static func configure(node: SKNode?, world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType, coordinates: TileViewCoordinates) {
        if let node = node {
            switch coordinates {
            case .chunk:
                // Uses chunk position because this node is a child of the chunk's node
                let chunkPos = pos3D.pos.chunkTilePos
                node.position = chunkPos.cgPoint * world.settings.tileViewWidthHeight
            case .world:
                node.position = pos3D.pos.cgPoint * world.settings.tileViewWidthHeight
            }
            node.zPosition = tileType.bigType.zPosition
            if world.settings.rotateTileViewBasedOnOrientation[tileType] ?? false {
                node.angle = tileType.orientation.asOptionalSide?.angle ?? Angle.zero
            }
        }
    }

    private let world: ReadonlyWorld
    private let pos3D: WorldTilePos3D
    private let tileType: TileType
    private let template: TileViewTemplate?
    private let glossMaskNode: SKNode?
    private let glossMaskChild: SKNode?

    private lazy var editorIndicatorNode: SKNode? = generateAndAddEditorIndicatorNode()

    private var settings: WorldSettings { world.settings }

    init(world: ReadonlyWorld, pos3D: WorldTilePos3D, tileType: TileType, coordinates: TileViewCoordinates, glossMaskNode: SKNode?) {
        self.world = world
        self.pos3D = pos3D
        self.tileType = tileType
        template = world.settings.tileViewTemplates[tileType]
        self.glossMaskNode = glossMaskNode
        glossMaskChild = glossMaskNode == nil ?
                nil :
                TileView.generateGlossNode(template: template, world: world, pos3D: pos3D, tileType: tileType, coordinates: coordinates)
        super.init(node: TileView.generateNode(template: template, world: world, pos3D: pos3D, tileType: tileType, coordinates: coordinates))

        updateEditorIndicator()
        world.didChangeEditorIndicatorVisibility.subscribe(observer: self, priority: .view) { (self) in
            self.updateEditorIndicator()
        }
    }

    // region editor node
    private func updateEditorIndicator() {
        editorIndicatorNode?.isHidden = !world.showEditingIndicators
    }

    private func generateAndAddEditorIndicatorNode() -> SKNode? {
        let editorIndicatorNode = template?.generateEditorIndicatorNode(world: world, pos3D: pos3D, tileType: tileType)
        if let editorIndicatorNode = editorIndicatorNode {
            // Need to subtract node's z-position because parent / child z-positions are additive,
            // and we want the editor indicator's z-position to be (relative to the node's parent)
            // at exactly TileType.editorIndicatorZPosition
            editorIndicatorNode.zPosition = TileType.editorIndicatorZPosition - node!.zPosition
            node!.addChild(editorIndicatorNode)
        }
        return editorIndicatorNode
    }
    // endregion

    // region placement and removal
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

        if let fadeAction = template?.fadeAction {
            node?.zPosition += TileType.fadingZPositionOffset
            node?.run(fadeAction) {
                super.removeFromParent()
                self.template?.didRemoveFromParent(node: self.node!)
            }
        } else {
            super.removeFromParent()
            template?.didRemoveFromParent(node: node!)
        }
    }
    // endregion
}

//
// Created by Jakob Hain on 5/29/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class InspectorContainerView: UXView {
    private static let backgroundTexture: SKTexture = SKTexture.withFilterModeNearest(textureName: "UI/InspectorBackground")
    private static let backgroundCenterRect: CGRect = CGRect(origin: CGPoint(x: 0, y: 0.5), size: CGSize.square(sideLength: 0.5))
    private static let backgroundExtraSize: CGSize = CGSize.square(sideLength: 12)

    private let editorTools: EditorTools
    private let world: ReadonlyStatelessWorld
    private let worldUrl: URL

    let node: SKNode
    private let backgroundNode: SKSpriteNode
    private var inspectorView: InspectorView? = nil {
        willSet { inspectorView?.set(parent: nil) }
        didSet {
            if let inspectorView = inspectorView {
                if let scene = scene {
                    inspectorView.set(scene: scene)
                }
                inspectorView.set(parent: node)
                inspectorView.node.zPosition = 1
                backgroundNode.size = inspectorView.topLeft.toSize + inspectorView.size + InspectorContainerView.backgroundExtraSize
                node.isHidden = false
            } else {
                node.isHidden = true
            }
        }
    }

    private weak var scene: SJScene? = nil {
        didSet {
            if let scene = scene {
                inspectorView?.set(scene: scene)
            }
        }
    }
    var size: CGSize { scene?.size ?? CGSize.zero }

    init(editorTools: EditorTools, world: ReadonlyStatelessWorld, worldUrl: URL) {
        self.editorTools = editorTools
        self.world = world
        self.worldUrl = worldUrl

        node = SKNode()
        node.isHidden = true

        backgroundNode = SKSpriteNode(texture: InspectorContainerView.backgroundTexture)
        backgroundNode.centerRect = InspectorContainerView.backgroundCenterRect
        backgroundNode.anchorPoint = UXSpriteAnchor
        backgroundNode.zPosition = 0
        backgroundNode.isUserInteractionEnabled = true
        node.addChild(backgroundNode)

        updateInspectorView()
        editorTools.didChangeInspector.subscribe(observer: self, priority: .view) { (self) in
            self.updateInspectorView()
        }
    }

    private func updateInspectorView() {
        if let inspector = editorTools.inspector {
            inspectorView = InspectorView(inspector: inspector, world: world, worldUrl: worldUrl)
        } else {
            inspectorView = nil
        }
    }

    func set(scene: SJScene) {
        self.scene = scene
    }
}

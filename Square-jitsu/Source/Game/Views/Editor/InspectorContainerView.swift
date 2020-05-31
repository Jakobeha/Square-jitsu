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

    let node: SKNode
    private let backgroundNode: SKSpriteNode
    private var inspectorView: InspectorView? = nil {
        willSet { inspectorView?.set(parent: nil) }
        didSet {
            if let inspectorView = inspectorView {
                inspectorView.set(sceneSize: sceneSize)
                inspectorView.set(parent: node)
                inspectorView.node.zPosition = 1
                backgroundNode.size = inspectorView.topLeft.toSize + inspectorView.size + InspectorContainerView.backgroundExtraSize
                node.isHidden = false
            } else {
                node.isHidden = true
            }
        }
    }

    private var sceneSize: CGSize = CGSize.zero {
        didSet { inspectorView?.set(sceneSize: sceneSize) }
    }
    var size: CGSize { sceneSize }

    init(editorTools: EditorTools) {
        self.editorTools = editorTools

        node = SKNode()
        node.isHidden = true

        backgroundNode = SKSpriteNode(texture: InspectorContainerView.backgroundTexture)
        backgroundNode.centerRect = InspectorContainerView.backgroundCenterRect
        backgroundNode.anchorPoint = UXSpriteAnchor
        backgroundNode.zPosition = 0
        backgroundNode.isUserInteractionEnabled = true
        node.addChild(backgroundNode)

        updateInspectorView()
        editorTools.didChangeInspector.subscribe(observer: self, priority: ObservablePriority.view) {
            self.updateInspectorView()
        }
    }

    private func updateInspectorView() {
        if let inspector = editorTools.inspector {
            inspectorView = InspectorView(inspector: inspector)
        } else {
            inspectorView = nil
        }
    }

    func set(sceneSize: CGSize) {
        self.sceneSize = sceneSize
    }
}

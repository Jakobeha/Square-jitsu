//
// Created by Jakob Hain on 5/24/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class GridView: UXView {
    private static let gridStrokeColor: SKColor = SKColor(white: 0.5, alpha: 0.25)
    private static let gridLineWidth: CGFloat = 1

    private let camera: Camera
    private let settings: WorldSettings

    private let gridNode: SKShapeNode = SKShapeNode()
    var node: SKNode { gridNode }

    private var sceneSize: CGSize = CGSize.zero {
        didSet { updateGridPath() }
    }
    var size: CGSize { sceneSize }

    init(camera: Camera, settings: WorldSettings) {
        self.camera = camera
        self.settings = settings

        configureGridNode()

        updateNodePositionForCameraChange()
        camera.didChange.subscribe(observer: self, priority: .view) { (self) in
            self.updateNodePositionForCameraChange()
        }
    }

    private func configureGridNode() {
        gridNode.fillColor = SKColor.clear
        gridNode.strokeColor = GridView.gridStrokeColor
        gridNode.lineWidth = GridView.gridLineWidth
    }

    private func updateGridPath() {
        let gridPath = settings.generateGridPathForView(sceneSize: sceneSize)

        gridNode.path = gridPath
    }

    private func updateNodePositionForCameraChange() {
        camera.inverseTransformUX(rootNode: gridNode)

        // So grid appears infinite
        gridNode.position %= settings.gridViewModulo
    }

    func set(scene: SJScene) {
        sceneSize = scene.size
    }
}

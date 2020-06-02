//
// Created by Jakob Hain on 5/24/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class GridView: UXView {
    private static let gridStrokeColor: SKColor = SKColor(white: 0.5, alpha: 0.5)
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
        camera.didChange.subscribe(observer: self, priority: .view) {
            self.updateNodePositionForCameraChange()
        }
    }

    private func configureGridNode() {
        gridNode.fillColor = SKColor.clear
        gridNode.strokeColor = GridView.gridStrokeColor
        gridNode.lineWidth = GridView.gridLineWidth
    }

    private func updateGridPath() {
        let bounds = CGRect(origin: CGPoint.zero, size: sceneSize).insetBy(sideLength: settings.tileViewWidthHeight)

        let gridPath = CGMutablePath()
        // Add vertical lines
        var nextVerticalLineX = bounds.minX
        while nextVerticalLineX < bounds.maxX {
            gridPath.move(to: CGPoint(x: nextVerticalLineX, y: bounds.minY))
            gridPath.addLine(to: CGPoint(x: nextVerticalLineX, y: bounds.maxY))

            nextVerticalLineX += settings.tileViewWidthHeight
        }
        // Add horizontal lines
        var nextHorizontalLineY = bounds.minY
        while nextHorizontalLineY < bounds.maxY {
            gridPath.move(to: CGPoint(x: bounds.minX, y: nextHorizontalLineY))
            gridPath.addLine(to: CGPoint(x: bounds.maxX, y: nextHorizontalLineY))

            nextHorizontalLineY += settings.tileViewWidthHeight
        }

        // gridNode.path = gridPath
    }

    private func updateNodePositionForCameraChange() {
        camera.inverseTransformUX(rootNode: gridNode)

        // So grid appears infinite
        gridNode.position %= settings.tileViewWidthHeight
    }

    func set(sceneSize: CGSize) {
        self.sceneSize = sceneSize
    }
}

//
// Created by Jakob Hain on 5/29/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class InspectorView: UXCompoundView {
    private static let subInspectorPadding: CGFloat = 12
    private static let subInspectorSpacing: CGFloat = subInspectorPadding
    private static let emptyInspectorText: Label = Label(text: "Nothing to inspect")
    static let maxInspectorWidth: CGFloat = 384

    private let inspector: Inspector
    private let worldUrl: URL
    private let settings: WorldSettings

    override var size: CGSize {
        super.size + CGSize.square(sideLength: InspectorView.subInspectorPadding)
    }

    init(inspector: Inspector, worldUrl: URL, settings: WorldSettings) {
        self.inspector = inspector
        self.worldUrl = worldUrl
        self.settings = settings
    }

    override func newBody() -> UXView {
        VStack(
            getChildViews(),
            spacing: InspectorView.subInspectorSpacing,
            topLeft: CGPoint(x: InspectorView.subInspectorPadding, y: InspectorView.subInspectorPadding)
        )
    }

    private func getChildViews() -> [UXView] {
        let subInspectorViews = getSubInspectorViews()
        if subInspectorViews.isEmpty {
            return [InspectorView.emptyInspectorText]
        } else {
            return subInspectorViews
        }
    }

    private func getSubInspectorViews() -> [LabeledSIV] {
        var views: [LabeledSIV] = []

        if let adjacentToSolidInspector = inspector.adjacentToSolidInspector {
            views.append(LabeledSIV(SideBasedOrientationSIV(adjacentToSolidInspector), label: "Connected side"))
        }
        if let directionToCornerInspector = inspector.directionToCornerInspector {
            views.append(LabeledSIV(CornerBasedOrientationSIV(directionToCornerInspector), label: "Corner this faces"))
        }
        if let edgeInspector = inspector.edgeInspector {
            views.append(LabeledSIV(SideBasedOrientationSIV(edgeInspector), label: "Edges"))
        }
        if let turretInspector = inspector.turretInspector {
            views.append(LabeledSIV(TurretSIV(turretInspector), label: "Turret initial angle"))
        }
        if let imageInspector = inspector.imageInspector {
            views.append(LabeledSIV(ImageSIV(imageInspector, settings: settings), label: "Image location"))
        }
        if let portalInspector = inspector.portalInspector {
            views.append(LabeledSIV(PortalSIV(portalInspector, worldUrl: worldUrl), label: "Destination level location"))
        }

        return views
    }
}
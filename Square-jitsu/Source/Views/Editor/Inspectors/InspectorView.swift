//
// Created by Jakob Hain on 5/29/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class InspectorView: UXCompoundView {
    private static let subInspectorPadding: CGFloat = 12
    private static let subInspectorSpacing: CGFloat = subInspectorPadding
    static let maxInspectorWidth: CGFloat = 384

    private let inspector: Inspector
    private let world: ReadonlyStatelessWorld
    private let worldUrl: URL

    private var settings: WorldSettings {
        world.settings
    }

    override var size: CGSize {
        super.size + CGSize.square(sideLength: InspectorView.subInspectorPadding)
    }

    init(inspector: Inspector, world: ReadonlyStatelessWorld, worldUrl: URL) {
        self.inspector = inspector
        self.world = world
        self.worldUrl = worldUrl
    }

    override func newBody() -> UXView {
        VStack(
            getChildViews(),
            spacing: InspectorView.subInspectorSpacing,
            topLeft: CGPoint(x: InspectorView.subInspectorPadding, y: InspectorView.subInspectorPadding)
        )
    }

    private func getChildViews() -> [UXView] {
        let tileNamesView = Label(text: tileNamesAsString)
        let subInspectorViews = getSubInspectorViews()
        return [tileNamesView] + subInspectorViews
    }

    private var tileNamesAsString: String {
        tileNames.joined(separator: ", ")
    }

    private var tileNames: Set<String> {
        Set(inspector.positions.map { position in
            let tileType = self.world[position]
            return self.settings.getUserFriendlyDescriptionOf(tileType: tileType)
        })
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
        if let freeSideSetInspector = inspector.freeSideSetInspector {
            views.append(LabeledSIV(SideBasedOrientationSIV(freeSideSetInspector), label: "Sides"))
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

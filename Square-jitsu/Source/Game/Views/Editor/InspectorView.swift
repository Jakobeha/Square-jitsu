//
// Created by Jakob Hain on 5/29/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class InspectorView: UXCompoundView {
    private static let subInspectorPadding: CGFloat = 12
    private static let subInspectorSpacing: CGFloat = subInspectorPadding
    private static let emptyInspectorText: Label = Label(text: "Nothing to inspect")

    private let inspector: Inspector

    override var size: CGSize {
        super.size + CGSize.square(sideLength: InspectorView.subInspectorPadding)
    }

    init(inspector: Inspector) {
        self.inspector = inspector
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
            views.append(LabeledSIV(ConnectedSideSIV(adjacentToSolidInspector), label: "Connected Side"))
        }
        if let turretInspector = inspector.turretInspector {
            views.append(LabeledSIV(TurretSIV(turretInspector), label: "Turret"))
        }

        return views
    }
}

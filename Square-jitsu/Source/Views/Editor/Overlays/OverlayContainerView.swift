//
// Created by Jakob Hain on 7/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class OverlayContainerView: UXCompoundView {
    private let overlayContainer: OverlayContainer

    private var sceneSize: CGSize {
        scene?.size ?? CGSize.zero
    }

    init(overlayContainer: OverlayContainer) {
        self.overlayContainer = overlayContainer
        super.init()

        overlayContainer.didPresentOverlay.subscribe(observer: self, priority: .view) { (self) in
            self.regenerateBody()
        }
        overlayContainer.didDismissOverlay.subscribe(observer: self, priority: .view) { (self, _) in
            self.regenerateBody()
        }
    }

    override func newBody() -> UXView {
        var views: [UXView] = getOverlayViews()
        if overlayContainer.preventTouchPropagation {
            let dimView = DimView()
            views.append(dimView)
        }
        return ZStack(views, topLeft: ConvertToUXCoords(size: sceneSize / 2).toPoint)
    }

    private func getOverlayViews() -> [OverlayView] {
        overlayContainer.overlays.reversed().map(NewOverlayView)
    }
}

//
// Created by Jakob Hain on 7/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class OverlayContainerView: UXCompoundView {
    private let overlayContainer: OverlayContainer

    init(overlayContainer: OverlayContainer) {
        self.overlayContainer = overlayContainer
        super.init()

        overlayContainer.didPresentOverlay.subscribe(observer: self, priority: .view, handler: regenerateBody)
        overlayContainer.didDismissOverlay.subscribe(observer: self, priority: .view, handler: regenerateBody)
    }

    override func newBody() -> UXView {
        var views: [UXView] = getOverlayViews()
        if overlayContainer.preventTouchPropagation {
            let dimView = DimView()
            views.insert(dimView, at: 0)
        }
        return ZStack(views)
    }

    private func getOverlayViews() -> [OverlayView] {
        overlayContainer.overlays.map(NewOverlayView)
    }
}

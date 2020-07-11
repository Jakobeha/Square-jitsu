//
// Created by Jakob Hain on 7/10/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

fileprivate let OverlayViews: [ObjectIdentifier:OverlayView.Type] = [
    ObjectIdentifier(Alert.self): AlertView.self
]

func NewOverlayView(overlay: Overlay) -> OverlayView {
    let overlayViewClass = OverlayViews[ObjectIdentifier(type(of: overlay))]!
    return overlayViewClass.init(overlay: overlay)
}

protocol OverlayView: UXView {
    init(overlay: Overlay)
}
//
// Created by Jakob Hain on 5/29/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Labeled sub-inspector view
class LabeledSIV: UXCompoundView {
    private static let labelSpacing: CGFloat = 4

    private let subInspectorView: UXView
    private let label: Label

    init(_ subInspectorView: UXView, label: String) {
        self.subInspectorView = subInspectorView
        self.label = Label(text: label)
    }

    override func newBody() -> UXView {
        VStack([
            label,
            subInspectorView
        ], spacing: LabeledSIV.labelSpacing)
    }
}

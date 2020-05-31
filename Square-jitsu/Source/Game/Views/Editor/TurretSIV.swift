//
// Created by Jakob Hain on 5/29/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Connected side sub inspector view
class TurretSIV: UXCompoundView {
    private let subInspector: TurretInspector

    init(_ subInspector: TurretInspector) {
        self.subInspector = subInspector
    }

    override func newBody() -> UXView {
        Slider(
            range: -Angle.right.toUnclamped...Angle.right.toUnclamped,
            values: subInspector.initialTurretDirections.map { angle in angle.toUnclamped }
        ) { newUnclampedAngle in
            let newAngle = Angle(newUnclampedAngle)
            self.subInspector.setInitialTurretDirections(to: newAngle)
        }
    }
}

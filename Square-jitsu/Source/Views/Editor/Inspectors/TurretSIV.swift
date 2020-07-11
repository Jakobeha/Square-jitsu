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
        // Want the range to be the entire left side of the unit circle
        Slider(
            range: TurretComponent.minRotation.toUnclamped...TurretComponent.maxRotation.toUnclamped,
            values: subInspector.initialTurretDirections.map { angle in (Angle.straight - angle).toUnclamped }
        ) { newUnclampedAngle in
            let newAngle = Angle.straight - Angle(newUnclampedAngle)
            self.subInspector.setInitialTurretDirections(to: newAngle)
        }
    }
}

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
        VStack([
            newInitialDirectionSlider(),
            newRotatesClockwiseSwitch()
        ].compacted)
    }

    private func newInitialDirectionSlider() -> UXView {
        // Want the range to be the entire left side of the unit circle
        Slider(
            owner: self,
            range: TurretComponent.minRotation.toUnclamped...TurretComponent.maxRotation.toUnclamped,
            values: subInspector.initialTurretDirections.map { angle in (Angle.straight - angle).toUnclamped }
        ) { (self, newUnclampedAngle) in
            let newAngle = Angle.straight - Angle(newUnclampedAngle)
            self.subInspector.setInitialTurretDirections(to: newAngle)
        }
    }

    private func newRotatesClockwiseSwitch() -> UXView? {
        // TODO: Make an actual switch for this
        if let rotatesClockwise = subInspector.rotatesClockwise {
            return TextButton(
                owner: self,
                text: rotatesClockwise ? "Rotate Counter-Clockwise" : "Rotate Clockwise",
                width: InspectorView.maxInspectorWidth
            ) { (self) in
                self.subInspector.rotatesClockwise = !rotatesClockwise
                self.regenerateBody()
            }
        } else {
            return nil
        }
    }
}

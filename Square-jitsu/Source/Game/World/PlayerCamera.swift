//
// Created by Jakob Hain on 5/7/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class PlayerCamera: Camera {
    /// Position without shake effect
    private var simplePosition: CGPoint = CGPoint.nan
    private var shake: CGFloat = 0

    private var shakeRng: SystemRandomNumberGenerator = SystemRandomNumberGenerator()
    private var currentShakeOffset: CGPoint = CGPoint.zero
    private var nextShakeOffset: CGPoint = CGPoint.zero

    func tick() {
        assert(world != nil, "can't tick player camera without world")

        updateSimplePosition()
        updateShake()
        updatePosition()
    }

    private func updateSimplePosition() {
        let settings = world!.settings
        let player = world!.player

        let newIdealSimplePosition = player.prev.locC!.position
        let newSimplePositionWithoutBoundaries = simplePosition.isNaN ? newIdealSimplePosition : CGPoint.lerp(
            start: simplePosition,
            end: newIdealSimplePosition,
            t: settings.cameraSpeed
        )
        simplePosition = applyBoundariesTo(newPosition: newSimplePositionWithoutBoundaries)
    }

    private func applyBoundariesTo(newPosition: CGPoint) -> CGPoint {
        let rectAt0 = WorldTileRect.around(cgRect: CGRect(
            center: CGPoint.zero,
            size: sizeInWorldCoords
        ))
        let rectAroundOldPosition = simplePosition.isNaN ?
            WorldTileRect.around(cgRect: CGRect(
                center: newPosition,
                size: CGSize.zero
            )) :
            WorldTileRect.around(cgRect: CGRect(
                center: simplePosition,
                size: sizeInWorldCoords
            ))
        let rectAroundNewPosition = WorldTileRect.around(cgRect: CGRect(
            center: newPosition,
            size: sizeInWorldCoords
        ))

        var resultPosition = newPosition
        for side in Side.allCases {
            let newTilePositions1DInThisDirection = ExplicitStepRange(
                start: rectAroundOldPosition.edgeAt(side: side),
                end: rectAroundNewPosition.edgeAt(side: side),
                step: side.isPositiveOnAxis ? 1 : -1
            )
            for newTilePos1D in newTilePositions1DInThisDirection {
                let otherDimension = side.axis.other
                let minOtherDimension = min(
                    rectAroundOldPosition.minOn(axis: otherDimension),
                    rectAroundNewPosition.minOn(axis: otherDimension)
                )
                let maxOtherDimension = max(
                    rectAroundOldPosition.maxOn(axis: otherDimension),
                    rectAroundNewPosition.maxOn(axis: otherDimension)
                )
                let newTilePositionsOtherDimension = minOtherDimension...maxOtherDimension
                for newTilePosOtherDimension in newTilePositionsOtherDimension {
                    let newTilePos = side.axis == .horizontal ?
                        WorldTilePos(x: newTilePos1D, y: newTilePosOtherDimension) :
                        WorldTilePos(x: newTilePosOtherDimension, y: newTilePos1D)
                    let newTileTypes = world![newTilePos]
                    let containsBoundaryForThisSide = newTileTypes.contains { newTileType in
                        newTileType.bigType == .cameraBoundary && newTileType.orientation.asSideSet.contains(side.toSet)
                    }
                    let containsShiftForThisSide = newTileTypes.contains { newTileType in
                        newTileType.bigType == .cameraBoundary &&
                        newTileType.smallType.isCameraBoundaryShift &&
                        newTileType.orientation.asSideSet.contains(side.opposite.toSet)
                    }
                    if containsShiftForThisSide {
                        let currentPositionOnAxis = resultPosition[side.axis]
                        let constrainedPositionOnAxis = CGFloat(newTilePos1D + rectAt0.edgeAt(side: side))
                        if side.isPositiveOnAxis ?
                            currentPositionOnAxis > constrainedPositionOnAxis :
                            currentPositionOnAxis < constrainedPositionOnAxis {
                            resultPosition[side.axis] = constrainedPositionOnAxis
                        }
                    } else if containsBoundaryForThisSide {
                        let currentPositionOnAxis = resultPosition[side.axis]
                        let constrainedPositionOnAxis = CGFloat(newTilePos1D - rectAt0.edgeAt(side: side))
                        if side.isPositiveOnAxis ?
                            currentPositionOnAxis > constrainedPositionOnAxis :
                            currentPositionOnAxis < constrainedPositionOnAxis {
                            resultPosition[side.axis] = constrainedPositionOnAxis
                        }
                        break
                    }
                }
            }
        }
        return resultPosition
    }

    private func updateShake() {
        let settings = world!.settings

        if shake > 0 {
            if (nextShakeOffset - currentShakeOffset).magnitude <= settings.shakeInterpolationDistanceBeforeChange {
                nextShakeOffset = CGPoint(magnitude: shake, directionFromOrigin: Angle.random(using: &shakeRng))
            }

            currentShakeOffset = CGPoint.lerp(start: currentShakeOffset, end: nextShakeOffset, t: settings.shakeInterpolationFractionPerFrame)
        } else {
            currentShakeOffset = CGPoint.zero
            nextShakeOffset = CGPoint.zero
        }

        shake = max(0, shake - (settings.shakeFade * settings.fixedDeltaTime))
    }

    private func updatePosition() {
        position = simplePosition + currentShakeOffset
    }

    func add(shake newShake: CGFloat) {
        shake += newShake
    }

    func reset() {
        simplePosition = CGPoint.nan
    }
}

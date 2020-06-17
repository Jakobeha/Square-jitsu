//
// Created by Jakob Hain on 5/8/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct AINinjaSystem: TopLevelSystem {
    let entity: Entity

    init(entity: Entity) {
        self.entity = entity
    }

    static func preTick(world: World) {}

    static func postTick(world: World) {}

    func tick() {
        if entity.next.anjC != nil {
            if let nextState = tryToTransitionState(prevState: entity.next.anjC!.state) {
                entity.next.anjC!.state = nextState
            }
        }
    }

    private func tryToTransitionState(prevState: AINinjaComponent.AIState) -> AINinjaComponent.AIState? {
        switch prevState {
        case .idle:
            guard let target = lookForTarget() else {
                return nil
            }

            return tryToJumpToSideOf(target: target)
        case .jumpingToSide(let lastPosition, target: let targetRef):
            if didLoseTarget(target: targetRef.deref) {
                return .idle
            } else {
                let target = targetRef.deref!

                if isMovingSlowEnoughToChangeState || farEnoughToPerformJumpToTarget(lastPosition: lastPosition) {
                    return jumpTowards(target: target)
                } else {
                    return nil
                }
            }
        case .jumpingToTarget(target: let targetRef):
            if didLoseTarget(target: targetRef.deref) {
                return .idle
            } else {
                let target = targetRef.deref!

                let idealJumpDirection = calculateDirectionToJumpTowards(target: target)
                let jumpSpeed = entity.next.dynC!.velocity.projectedOnto(angle: idealJumpDirection)
                if isMovingSlowEnoughToChangeState {
                    return jumpTowards(target: target)
                } else if jumpSpeed < 0 {
                    // Moving away from target, keep going but now we percieve as jumping to side from this position
                    return .jumpingToSide(lastPosition: entity.next.locC!.position, target: EntityRef(target))
                } else {
                    return nil
                }
            }
        }
    }

    private func lookForTarget() -> Entity? {
        world.entities.filter(isValidTarget).min { getDistanceFrom(target: $0) < getDistanceFrom(target: $1) }
    }

    private func isValidTarget(entity otherEntity: Entity) -> Bool {
        if otherEntity == entity || !entity.next.anjC!.targetTypes.contains(otherEntity.type) {
            return false
        }

        if otherEntity.next.locC == nil {
            Logger.warnSettingsAreInvalid("AI ninja can target entity which doesn't have a position (locC) according to settings, but this is impossible")
            return false
        }

        let distance = (entity.next.locC!.position - otherEntity.next.locC!.position).magnitude
        if distance > entity.next.anjC!.incomingTargetDistanceBeforeFirstJump {
            return false
        }

        return true
    }

    private func getDistanceFrom(target: Entity) -> CGFloat {
        (target.next.locC!.position - entity.next.locC!.position).magnitude
    }

    private func getDirectionTowards(target: Entity) -> Angle {
        (target.next.locC!.position - entity.next.locC!.position).directionFromOrigin
    }

    private func didLoseTarget(target: Entity?) -> Bool {
        if let target = target {
            let distanceFromTarget = (entity.next.locC!.position - target.next.locC!.position).magnitude
            return distanceFromTarget > entity.next.anjC!.distanceBeforeTargetLost
        } else {
            return true
        }
    }

    private func calculateDirectionToJumpToSideOf(target: Entity) -> Angle? {
        let targetDirection = getDirectionTowards(target: target)

        let possibleJumpDirections = [
            targetDirection + entity.next.anjC!.firstJumpAngle.toUnclamped,
            targetDirection - entity.next.anjC!.firstJumpAngle.toUnclamped
        ]
        let jumpDirection = possibleJumpDirections.first { possibleJumpDirection in
            entity.next.colC!.adjacentSides.isDisjoint(with: possibleJumpDirection.quadrantCorner.toNearestSides)
        } ?? possibleJumpDirections.first { possibleJumpDirection in
            !entity.next.colC!.adjacentSides.contains(possibleJumpDirection.quadrantCorner.toNearestSides)
        }

        return jumpDirection
    }

    private func calculateDirectionToJumpTowards(target: Entity) -> Angle {
        // TODO: Factor speed of target and distance for collision on constant velocity
        getDirectionTowards(target: target)
    }

    /// Returns an `AIState` if successful
    private func tryToJumpToSideOf(target: Entity) -> AINinjaComponent.AIState? {
        guard let jumpDirection = calculateDirectionToJumpToSideOf(target: target) else {
            return nil
        }

        entity.next.nijC!.actionState = .doPrimary(direction: jumpDirection)
        return .jumpingToSide(lastPosition: entity.next.locC!.position, target: EntityRef(target))
    }

    private func jumpTowards(target: Entity) -> AINinjaComponent.AIState {
        let jumpDirection = calculateDirectionToJumpTowards(target: target)

        entity.next.nijC!.actionState = .doPrimary(direction: jumpDirection)
        return .jumpingToTarget(target: EntityRef(target))
    }

    private func farEnoughToPerformJumpToTarget(lastPosition: CGPoint) -> Bool {
        let currentPosition = entity.next.locC!.position
        let distanceFromLastPosition = (currentPosition - lastPosition).magnitude

        return distanceFromLastPosition >= entity.next.anjC!.distanceBeforeConsecutiveJumps
    }

    private var isMovingSlowEnoughToChangeState: Bool {
        entity.next.dynC!.velocity.magnitude < entity.next.anjC!.minSpeedToNotWantStateChange ||
        entity.next.dynC!.angularVelocity.isAbsoluteSmallerThan(angle: entity.next.anjC!.minAngularSpeedToNotWantStateChange)
    }
}

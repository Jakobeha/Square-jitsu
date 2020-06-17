//
// Created by Jakob Hain on 5/7/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct AINinjaComponent: SingleSettingCodable, Codable {
    enum AIState {
        case idle
        case jumpingToSide(lastPosition: CGPoint, target: EntityRef)
        case jumpingToTarget(target: EntityRef)

        var isIdle: Bool {
            switch self {
            case .idle:
                return true
            case .jumpingToSide(lastPosition: _, let target):
                return target.deref == nil
            case .jumpingToTarget(let target):
                return target.deref == nil
            }
        }
    }

    var incomingTargetDistanceBeforeFirstJump: CGFloat
    var firstJumpAngle: Angle
    var distanceBeforeConsecutiveJumps: CGFloat
    var distanceBeforeTargetLost: CGFloat
    var minSpeedToNotWantStateChange: CGFloat
    var minAngularSpeedToNotWantStateChange: Angle
    var targetTypes: TileTypePred

    var state: AIState = .idle

    // region encoding and decoding
    enum CodingKeys: String, CodingKey {
        case incomingTargetDistanceBeforeFirstJump
        case firstJumpAngle
        case distanceBeforeConsecutiveJumps
        case distanceBeforeTargetLost
        case minSpeedToNotWantStateChange
        case minAngularSpeedToNotWantStateChange
        case targetTypes
    }

    typealias AsSetting = StructSetting<AINinjaComponent>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "incomingTargetDistanceBeforeFirstJump": CGFloatRangeSetting(0...16),
            "firstJumpAngle": AngleSetting(),
            "distanceBeforeConsecutiveJumps": CGFloatRangeSetting(0...16),
            "distanceBeforeTargetLost": CGFloatRangeSetting(0...16),
            "minSpeedToNotWantStateChange": CGFloatRangeSetting(0...16),
            "minAngularSpeedToNotWantStateChange": UnclampedAngleSetting(),
            "targetTypes": TileTypePredSetting()
        ], optionalFields: [:])
    }
    // endregion
}

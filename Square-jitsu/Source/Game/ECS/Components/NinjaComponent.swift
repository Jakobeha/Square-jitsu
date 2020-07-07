//
// Created by Jakob Hain on 5/7/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct NinjaComponent: SingleSettingCodable, Codable {
    static let maxOffsetFromOverriddenDirectionForJumpToStillOccur: Angle = Angle.right / 1.5

    enum ActionState: Equatable {
        case idle
        case doJump(direction: Angle)
        case doThrow(direction: Angle)
    }

    var jumpSpeed: CGFloat
    var jumpAngularSpeed: UnclampedAngle
    /// # of possible jumps after jumping off of a solid without a background,
    /// but whenever the ninja jumps off a background this decreases anyways
    var minNumJumpsWithoutBackground: Int

    var actionState: ActionState = .idle
    /// Current # of possible jumps without a background,
    /// but whenever the ninja jumps off a background this decreases anyways
    var numJumpsWithoutBackgroundRemaining: Int = 0
    var backgroundTypesUsed: Set<TileType> = []

    // region encoding and decoding
    enum CodingKeys: String, CodingKey {
        case jumpSpeed
        case jumpAngularSpeed
        case minNumJumpsWithoutBackground
    }

    typealias AsSetting = StructSetting<NinjaComponent>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "jumpSpeed": CGFloatRangeSetting(0...128),
            "jumpAngularSpeed": UnclampedAngleSetting(),
            "minNumJumpsWithoutBackground": IntRangeSetting(0...16)
        ], optionalFields: [:])
    }
    // endregion
}

// Generated using Sourcery 0.18.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import SpriteKit

// From https://raw.githubusercontent.com/krzysztofzablocki/Sourcery/master/Templates/Templates/AutoCodable.swifttemplate

extension TurretComponent.HowToFire {

    enum CodingKeys: String, CodingKey {
        case consistent
        case burst
        case continuous
        case projectileSpeed
        case delay
        case delayBetweenBursts
        case numShotsInBurst
        case delayInBurst
        case projectileEndTiles
    }

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.allKeys.contains(.consistent), try container.decodeNil(forKey: .consistent) == false {
            let associatedValues = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .consistent)
            let projectileSpeed = try associatedValues.decode(CGFloat.self, forKey: .projectileSpeed)
            let delay = try associatedValues.decode(CGFloat.self, forKey: .delay)
            self = .consistent(projectileSpeed: projectileSpeed, delay: delay)
            return
        }
        if container.allKeys.contains(.burst), try container.decodeNil(forKey: .burst) == false {
            let associatedValues = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .burst)
            let projectileSpeed = try associatedValues.decode(CGFloat.self, forKey: .projectileSpeed)
            let delayBetweenBursts = try associatedValues.decode(CGFloat.self, forKey: .delayBetweenBursts)
            let numShotsInBurst = try associatedValues.decode(Int.self, forKey: .numShotsInBurst)
            let delayInBurst = try associatedValues.decode(CGFloat.self, forKey: .delayInBurst)
            self = .burst(projectileSpeed: projectileSpeed, delayBetweenBursts: delayBetweenBursts, numShotsInBurst: numShotsInBurst, delayInBurst: delayInBurst)
            return
        }
        if container.allKeys.contains(.continuous), try container.decodeNil(forKey: .continuous) == false {
            let associatedValues = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .continuous)
            let projectileEndTiles = try associatedValues.decode(TileTypePred.self, forKey: .projectileEndTiles)
            self = .continuous(projectileEndTiles: projectileEndTiles)
            return
        }
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case"))
    }

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .consistent(projectileSpeed, delay):
            var associatedValues = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .consistent)
            try associatedValues.encode(projectileSpeed, forKey: .projectileSpeed)
            try associatedValues.encode(delay, forKey: .delay)
        case let .burst(projectileSpeed, delayBetweenBursts, numShotsInBurst, delayInBurst):
            var associatedValues = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .burst)
            try associatedValues.encode(projectileSpeed, forKey: .projectileSpeed)
            try associatedValues.encode(delayBetweenBursts, forKey: .delayBetweenBursts)
            try associatedValues.encode(numShotsInBurst, forKey: .numShotsInBurst)
            try associatedValues.encode(delayInBurst, forKey: .delayInBurst)
        case let .continuous(projectileEndTiles):
            var associatedValues = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .continuous)
            try associatedValues.encode(projectileEndTiles, forKey: .projectileEndTiles)
        }
    }

}

extension TurretComponent.RotationPattern {

    enum CodingKeys: String, CodingKey {
        case neverRotate
        case rotateContinuously
        case rotateToTarget
        case rotateToTargetInstantly
        case speed
    }

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.allKeys.contains(.neverRotate), try container.decodeNil(forKey: .neverRotate) == false {
            self = .neverRotate
            return
        }
        if container.allKeys.contains(.rotateContinuously), try container.decodeNil(forKey: .rotateContinuously) == false {
            let associatedValues = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .rotateContinuously)
            let speed = try associatedValues.decode(UnclampedAngle.self, forKey: .speed)
            self = .rotateContinuously(speed: speed)
            return
        }
        if container.allKeys.contains(.rotateToTarget), try container.decodeNil(forKey: .rotateToTarget) == false {
            let associatedValues = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .rotateToTarget)
            let speed = try associatedValues.decode(UnclampedAngle.self, forKey: .speed)
            self = .rotateToTarget(speed: speed)
            return
        }
        if container.allKeys.contains(.rotateToTargetInstantly), try container.decodeNil(forKey: .rotateToTargetInstantly) == false {
            self = .rotateToTargetInstantly
            return
        }
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case"))
    }

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .neverRotate:
            _ = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .neverRotate)
        case let .rotateContinuously(speed):
            var associatedValues = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .rotateContinuously)
            try associatedValues.encode(speed, forKey: .speed)
        case let .rotateToTarget(speed):
            var associatedValues = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .rotateToTarget)
            try associatedValues.encode(speed, forKey: .speed)
        case .rotateToTargetInstantly:
            _ = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .rotateToTargetInstantly)
        }
    }

}

extension TurretComponent.SpreadPattern {

    enum CodingKeys: String, CodingKey {
        case fireStraight
        case fireAround
        case totalNumProjectiles
    }

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.allKeys.contains(.fireStraight), try container.decodeNil(forKey: .fireStraight) == false {
            self = .fireStraight
            return
        }
        if container.allKeys.contains(.fireAround), try container.decodeNil(forKey: .fireAround) == false {
            let associatedValues = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .fireAround)
            let totalNumProjectiles = try associatedValues.decode(Int.self, forKey: .totalNumProjectiles)
            self = .fireAround(totalNumProjectiles: totalNumProjectiles)
            return
        }
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case"))
    }

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .fireStraight:
            _ = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .fireStraight)
        case let .fireAround(totalNumProjectiles):
            var associatedValues = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .fireAround)
            try associatedValues.encode(totalNumProjectiles, forKey: .totalNumProjectiles)
        }
    }

}

extension TurretComponent.WhenToFire {

    enum CodingKeys: String, CodingKey {
        case alwaysFire
        case fireOnSeek
    }

    internal init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        let enumCase = try container.decode(String.self)
        switch enumCase {
        case CodingKeys.alwaysFire.rawValue: self = .alwaysFire
        case CodingKeys.fireOnSeek.rawValue: self = .fireOnSeek
        default: throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case '\(enumCase)'"))
        }
    }

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .alwaysFire: try container.encode(CodingKeys.alwaysFire.rawValue)
        case .fireOnSeek: try container.encode(CodingKeys.fireOnSeek.rawValue)
        }
    }

}

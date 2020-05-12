//
// Created by Jakob Hain on 5/11/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

enum GrabState: Equatable {
    case idle
    case grabbed(grabber: EntityRef)
    /// Thrown (until hitting a solid)
    case thrown(thrower: EntityRef)

    var isIdle: Bool {
        switch self {
        case .idle:
            return true
        case .grabbed(grabber: _), .thrown(thrower: _):
            return false
        }
    }

    var isGrabbed: Bool {
        switch self {
        case .grabbed(grabber: _):
            return true
        case .idle, .thrown(thrower: _):
            return false
        }
    }

    var isThrown: Bool {
        switch self {
        case .thrown(thrower: _):
            return true
        case .idle, .grabbed(grabber: _):
            return false
        }
    }

    var grabbedOrThrownBy: Entity? {
        switch self {
        case .idle:
            return nil
        case .grabbed(let grabber):
            return grabber.deref
        case .thrown(let thrower):
            return thrower.deref
        }
    }
}
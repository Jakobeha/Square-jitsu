//
// Created by Jakob Hain on 5/18/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

enum EditMoveState {
    case notStarted
    case inProgress(start: TouchPos, end: TouchPos)

    var isStarted: Bool {
        switch self {
        case .notStarted:
            return false
        case .inProgress(start: _, end: _):
            return true
        }
    }

    func afterTouchDown(firstTouchPos: TouchPos) -> EditMoveState {
        switch self {
        case .notStarted:
            return .inProgress(start: firstTouchPos, end: firstTouchPos)
        case .inProgress(start: _, end: _):
            fatalError("illegal state - afterTouchDown called on edit move state in progress")
        }
    }

    func afterTouchMove(nextTouchPos: TouchPos) -> EditMoveState {
        switch self {
        case .notStarted:
            fatalError("illegal state - afterTouchMove called on edit move state not started")
        case .inProgress(let start, end: _):
            return .inProgress(start: start, end: nextTouchPos)
        }
    }

    func distanceMovedAfterTouchUp(finalTouchPos: TouchPos) -> RelativePos {
        let finalState = afterTouchMove(nextTouchPos: finalTouchPos)
        switch finalState {
        case .notStarted:
            fatalError("illegal state - distanceMovedAfterTouchUp called on edit move state not started")
        case .inProgress(let start, let end):
            return end.worldTilePos - start.worldTilePos
        }
    }
}

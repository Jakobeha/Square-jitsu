//
// Created by Jakob Hain on 5/8/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct Touch {
    private static let maxPriorStateDurationRecorded: CGFloat = 1.0
    private static let maxDurationForVelocityEstimation: CGFloat = 1.0 / 16

    struct TemporalState {
        let timestamp: TimeInterval
        let position: CGPoint

        init(uiTouch: UITouch, container: SKScene) {
            timestamp = uiTouch.timestamp
            position = TouchPos.getPosition(uiTouch: uiTouch, container: container)
        }
    }

    let id: ObjectIdentifier
    let startTimestamp: TimeInterval
    var phase: TouchPhase
    private(set) var priorStates: [TemporalState] = []

    var currentState: TemporalState { priorStates.last! }
    var currentVelocity: CGPoint { getVelocity(usingPriorStates: ArraySlice(priorStates)) }

    init(uiTouch: UITouch, container: SKScene) {
        assert(uiTouch.phase == .began, "Touch instance should be created with beginning touch")
        id = uiTouch.id
        startTimestamp = uiTouch.timestamp
        phase = .began
        priorStates.append(TemporalState(uiTouch: uiTouch, container: container))
    }

    func getPriorStates(sinceTimestamp lastTimestamp: TimeInterval) -> ArraySlice<TemporalState> {
        priorStates.drop { priorState in priorState.timestamp > lastTimestamp}
    }

    func getLatestStateWhenVelocityWas(atMost maxVelocityMagnitude: CGFloat) -> TemporalState? {
        getLatestStateWhenVelocity { $0.magnitude <= maxVelocityMagnitude }
    }

    func getLatestStateWhenVelocityWas(atLeast minVelocityMagnitude: CGFloat) -> TemporalState? {
        getLatestStateWhenVelocity { $0.magnitude >= minVelocityMagnitude }
    }

    private func getLatestStateWhenVelocity(satisfies predicate: (CGPoint) -> Bool) -> TemporalState? {
        for numToDrop in 0..<priorStates.count {
            let priorStatesAtTimestamp = priorStates.dropLast(numToDrop)
            let stateAtTimestamp = priorStatesAtTimestamp.last!
            let velocityAtTimestamp = getVelocity(usingPriorStates: priorStatesAtTimestamp)
            if predicate(velocityAtTimestamp) {
                return stateAtTimestamp
            }
        }
        return nil
    }

    func getVelocity(sinceTimestamp lastTimestamp: TimeInterval) -> CGPoint {
        assert(lastTimestamp >= startTimestamp, "can't get velocity before start timestamp")
        return getVelocity(usingPriorStates: getPriorStates(sinceTimestamp: lastTimestamp))
    }

    private func getVelocity(usingPriorStates priorStates: ArraySlice<TemporalState>) -> CGPoint {
        let lastStateSinceTimestamp = priorStates.last!

        var totalPositionOffset = CGPoint.zero
        var totalTimeElapsed: CGFloat = 0
        for priorState in priorStates.reversed() {
            let timeSinceLast = CGFloat(lastStateSinceTimestamp.timestamp - priorState.timestamp)
            totalPositionOffset = lastStateSinceTimestamp.position - priorState.position
            totalTimeElapsed = timeSinceLast
            if timeSinceLast > Touch.maxDurationForVelocityEstimation {
                break
            }
        }
        let average = totalTimeElapsed == 0 ? CGPoint.zero : totalPositionOffset / totalTimeElapsed
        return average
    }

    mutating func updateFrom(uiTouch: UITouch, container: SKScene) {
        assert(uiTouch.id == id, "Touch instance doesn't have the same id as the UITouch it's being updated from")
        while !priorStates.isEmpty && CGFloat(uiTouch.timestamp - priorStates.first!.timestamp) > Touch.maxPriorStateDurationRecorded {
            priorStates.remove(at: 0)
        }
        priorStates.append(TemporalState(uiTouch: uiTouch, container: container))
    }
}

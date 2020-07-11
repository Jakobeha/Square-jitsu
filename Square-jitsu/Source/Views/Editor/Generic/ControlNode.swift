//
// Created by Jakob Hain on 5/30/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

class ControlNode: SKNode {
    private let _didTouchDown: Publisher<()> = Publisher()
    private let _didTouchMove: Publisher<[CGPoint]> = Publisher()
    private let _didTouchUp: Publisher<()> = Publisher()
    private let _didPress: Publisher<()> = Publisher()
    var didTouchDown: Observable<()> { Observable(publisher: _didTouchDown) }
    /// Not sure if UIControls do this, but this will always fire with the same position before a
    /// `didTouchUp` event unless there is a cancel, so you can handle all touch position changes
    /// with just this observable
    var didTouchMove: Observable<[CGPoint]> { Observable(publisher: _didTouchMove) }
    /// Unlike UIControls, this also fires if the touch was cancelled
    var didTouchUp: Observable<()> { Observable(publisher: _didTouchUp) }
    /// Fires on touch up but not cancel
    var didPress: Observable<()> { Observable(publisher: _didPress) }

    var size: CGSize

    var isPressed: Bool = false

    var touchCaptureRect: CGRect {
        ConvertToUXCoords(rect: CGRect(origin: CGPoint.zero, size: size).insetBy(sideLength: -ControlNode.touchCaptureRectOutset))
    }

    var isEnabled: Bool = true

    private static let touchCaptureRectOutset: CGFloat = 32

    init(size: CGSize) {
        self.size = size
        super.init()
        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented in ControlNode")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesMaybePressed()
        if !isPressed {
            super.touchesBegan(touches, with: event)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesMaybePressed()
        touchesMaybeMoved(event: event!)
        touchesMaybeReleased(event: event!, wouldBeCancel: true)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesMaybeMoved(event: event!)
        touchesMaybeReleased(event: event!, wouldBeCancel: false)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesMaybeReleased(event: event!, wouldBeCancel: true)
    }

    private func touchesMaybePressed() {
        if !isPressed && isEnabled {
            isPressed = true
            _didTouchDown.publish()
        }
    }

    private func touchesMaybeMoved(event: UIEvent) {
        if isPressed {
            let touchPositions = event.allTouches!.map { touch in touch.location(in: self) }
            _didTouchMove.publish(touchPositions)
        }
    }

    private func touchesMaybeReleased(event: UIEvent, wouldBeCancel: Bool) {
        if isPressed {
            let capturesATouch = event.allTouches!.contains(where: captures)
            if !capturesATouch {
                isPressed = false
                _didTouchUp.publish()
                if !wouldBeCancel {
                    _didPress.publish()
                }
            }
        }
    }

    private func captures(touch: UITouch) -> Bool {
        !touch.isEndedOrExited && touchCaptureRect.contains(touch.location(in: self))
    }
}

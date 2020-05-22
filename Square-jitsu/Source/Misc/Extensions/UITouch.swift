//
// Created by Jakob Hain on 5/8/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import UIKit

extension UITouch {
    var id: ObjectIdentifier { ObjectIdentifier(self) }

    var isEndedOrExited: Bool {
        switch phase {
        case .began, .stationary, .moved, .regionEntered, .regionMoved:
            return false
        case .ended, .cancelled, .regionExited:
            return true
        @unknown default:
            fatalError("isEndedOrExited - unhandled future touch phawe \(phase)")
        }
    }
}

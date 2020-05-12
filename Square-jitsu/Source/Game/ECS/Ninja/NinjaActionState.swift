//
// Created by Jakob Hain on 5/12/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

enum NinjaActionState: Equatable {
    case idle
    case doPrimary(direction: Angle)
}

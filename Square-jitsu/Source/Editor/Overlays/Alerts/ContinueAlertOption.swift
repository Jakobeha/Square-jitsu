//
// Created by Jakob Hain on 7/11/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

enum ContinueAlertOption: AlertOption {
    case `continue`

    var description: String {
        switch self {
        case .continue:
            return "Continue"
        }
    }
}
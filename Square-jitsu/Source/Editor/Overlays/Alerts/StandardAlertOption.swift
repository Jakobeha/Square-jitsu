//
// Created by Jakob Hain on 7/11/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

enum StandardAlertOption: AlertOption {
    case cancel
    case ok

    var description: String {
        switch self {
        case .cancel:
            return "Cancel"
        case .ok:
            return "Ok"
        }
    }
}

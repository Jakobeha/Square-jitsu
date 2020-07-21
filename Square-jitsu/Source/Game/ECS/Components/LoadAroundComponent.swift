//
// Created by Jakob Hain on 5/4/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct LoadAroundComponent: SingleSettingCodable, Codable {
    // region encoding and decoding
    typealias AsSetting = StructSetting<LoadAroundComponent>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [:], optionalFields: [:])
    }
    // endregion
}

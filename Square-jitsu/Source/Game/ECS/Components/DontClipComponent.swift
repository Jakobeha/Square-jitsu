//
// Created by Jakob Hain on 6/22/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct DontClipComponent: SingleSettingCodable, Codable {
    // region encoding and decoding
    typealias AsSetting = StructSetting<DontClipComponent>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [:], optionalFields: [:])
    }
    // endregion
}

//
// Created by Jakob Hain on 7/7/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

struct PortalMetadata: TileMetadata, SingleSettingCodable {
    var relativePathToDestination: String

    // region encoding and decoding
    typealias AsSetting = StructSetting<PortalMetadata>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "relativePathToDestination": StringSetting()
        ], optionalFields: [:])
    }
    // endregion
}

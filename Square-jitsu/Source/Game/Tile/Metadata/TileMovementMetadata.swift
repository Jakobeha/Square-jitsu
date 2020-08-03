//
// Created by Jakob Hain on 7/28/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

/// Different than other tile metadatas in that all tiles may or may not have this,
/// whereas regular metadatas some tiles always have and some tiles never have.
/// Also, this is stored separately from regular metadatas and tiles can have this metadata and a regular metadata.
struct TileMovementMetadata: SingleSettingCodable {
    static let `default`: TileMovementMetadata = TileMovementMetadata(offset: RelativePos.zero, repeatMode: .backAndForth)

    enum RepeatMode: SimpleEnumSettingCodable {
        case stopAtEnd
        case loop
        case backAndForth
    }

    var offset: RelativePos
    var repeatMode: RepeatMode

    // region encoding and decoding
    typealias AsSetting = StructSetting<TileMovementMetadata>

    static func newSetting() -> AsSetting {
        StructSetting(requiredFields: [
            "offset": RelativePosSetting(),
            "repeatMode": RepeatMode.newSetting()
        ], optionalFields: [:])
    }
    // endregion
}

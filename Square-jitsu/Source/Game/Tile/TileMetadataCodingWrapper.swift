//
// Created by Jakob Hain on 5/17/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

/// Hacky class which, when "decoded" and "encoded",
/// forwards the decoder / encoder to the current metadata so it can decode / encode itself.
class TileMetadataCodingWrapper: Codable {
    static var metadataBeingCoded: TileMetadata? {
        get { Thread.current.threadDictionary[threadLocalKey] as! TileMetadata? }
        set { Thread.current.threadDictionary[threadLocalKey] = newValue }
    }
    private static var threadLocalKey: Any { ObjectIdentifier(self) }

    required init(from decoder: Decoder) throws {
        try TileMetadataCodingWrapper.metadataBeingCoded!.decode(from: decoder)
    }

    init() {}

    func encode(to encoder: Encoder) throws {
        try TileMetadataCodingWrapper.metadataBeingCoded!.encode(to: encoder)
    }
}

//
// Created by Jakob Hain on 5/3/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

struct TileType: Equatable, Hashable, Codable, CompactCodableByValue, HasDefault, LosslessStringConvertible {
    static let air: TileType = TileType(bigType: TileBigType.air)
    static let basicBackground: TileType = TileType(bigType: TileBigType.background)
    static let basicOverlapSensitiveBackground: TileType = TileType(bigType: TileBigType.overlapSensitiveBackground)
    static let basicSolid: TileType = TileType(bigType: TileBigType.solid)
    static let basicAdjacentSensitiveSolid: TileType = TileType(bigType: TileBigType.adjacentSensitiveSolid)
    static let basicIce: TileType = TileType(bigType: TileBigType.ice)
    static let player: TileType = TileType(bigType: TileBigType.player)
    static let basicEnemy: TileType = TileType(bigType: TileBigType.enemy)
    static let basicShuriken: TileType = TileType(bigType: TileBigType.shuriken)

    static func basicTurret(side: Side) -> TileType {
        TileType(bigType: TileBigType.turret, smallType: TileSmallType(0), orientation: TileOrientation(side: side))
    }

    static func burstTurret(side: Side) -> TileType {
        TileType(bigType: TileBigType.turret, smallType: TileSmallType(1), orientation: TileOrientation(side: side))
    }

    static func filler(type: TileFillerType, id: Int, direction: Side, targetLayer: Int) -> TileType {
        TileType(
            bigType: .filler,
            smallType: TileSmallType(fillerData: TileFillerData(type: type, id: id)),
            orientation: TileOrientation(fillerOrientation: TileFillerOrientation(direction: direction, targetLayer: targetLayer))
        )
    }

    /// This uses 0-based indexing, so 0 = highest, 1 = 2nd highest, etc.
    static func indexOfNthHighestLayerIn(array: [TileType], n: Int) -> Int {
        array.lastIndex(of: typeWithNthHighestLayerIn(array: array, n: n))!
    }

    private static func typeWithNthHighestLayerIn(array: [TileType], n: Int) -> TileType {
        array.filter { type in
            type != TileType.air
        }.sorted { lhs, rhs in
            lhs.bigType.layer > rhs.bigType.layer
        }.getIfPresent(at: n) ?? TileType.air
    }

    static let defaultValue: TileType = air

    /// All z-positions are less than this, adds 1 for custom z-positions in settings
    static let zPositionUpperBound: CGFloat = CGFloat(TileLayer.allCases.count) + 1
    static let editorIndicatorZPosition = zPositionUpperBound - CGFloat.epsilon
    static let fadingZPositionOffset: CGFloat = 0.5 / CGFloat(TileBigType.allCases.count)
    static let smallestZPositionOffset: CGFloat = 0.25 / CGFloat(TileBigType.allCases.count)

    static let unknownDescription: String = "???"

    static func typesCanOverlap(_ lhs: TileType, _ rhs: TileType) -> Bool {
        lhs != rhs &&
        (TileLayer.layersCanOverlap(lhs.bigType.layer, rhs.bigType.layer) ||
         lhs.occupiedSides.isDisjoint(with: rhs.occupiedSides))
    }

    var bigType: TileBigType
    var smallType: TileSmallType
    var orientation: TileOrientation

    var isDefault: Bool { self == TileType.defaultValue }

    /// - Note: If you change this, also change TileTypeSet.containsBackground
    var isBackground: Bool { bigType.layer == .background }

    /// - Note: If you change this, also change TileTypeSet.containsSolid and TileTypePred1Way.insertSolidTypes
    var isSolid: Bool { bigType.layer == .solid || bigType.layer == .iceSolid || bigType == .solidEdge }

    var blocksVision: Bool {
        isSolid && bigType != .glassSolid
    }

    var occupiedSides: SideSet {
        bigType.layer.doTilesOccupySides ? orientation.asSideSet : SideSet.all
    }

    /// Whether the tile would be visible or have any effect if placed in game.
    /// If not, it won't actually be placed
    var isMeaninglessInGame: Bool {
        occupiedSides.isEmpty
    }

    var withDefaultOrientation: TileType {
        get { TileType(bigType: bigType, smallType: smallType) }
        set {
            bigType = newValue.bigType
            smallType = newValue.smallType
        }
    }

    init(bigType: TileBigType, smallType: TileSmallType = TileSmallType(0), orientation: TileOrientation = TileOrientation.none) {
        self.bigType = bigType
        self.smallType = smallType
        self.orientation = orientation
    }

    /// If this tile occupies sides based on its orientation,
    /// will combine the orientations treating them as side sets.
    /// Otherwise will replace this type's orientation with the given orientation
    func mergedOrReplaced(orientation: TileOrientation) -> TileType {
        let mergedOrientation = bigType.layer.doTilesOccupySides ?
            TileOrientation(sideSet: self.orientation.asSideSet.union(orientation.asSideSet)) :
            orientation
        var result = self
        result.orientation = mergedOrientation
        return result
    }

    // region encoding and decoding
    init?(_ description: String) {
        let components = description.split(separator: "/")
        if components.count < 1 {
            return nil
        }

        guard let bigType = TileBigType(String(components[0])) else {
            return nil
        }

        guard let smallType = components.count < 2 ? TileSmallType(0) : TileSmallType(String(components[1])) else {
            return nil
        }

        guard let orientation = components.count < 3 ? TileOrientation.none : TileOrientation(String(components[1])) else {
            return nil
        }

        if components.count > 3 {
            return nil
        }

        self = TileType(bigType: bigType, smallType: smallType, orientation: orientation)
    }

    var descriptionDifferentFromBigType: String {
        if orientation != TileOrientation.none {
            return "\(bigType)/\(smallType)\(orientation)"
        } else {
            return "\(bigType)/\(smallType)"
        }
    }

    var description: String {
        if orientation != TileOrientation.none {
            return "\(bigType)/\(smallType)/\(orientation)"
        } else if smallType != TileSmallType(0) {
            return "\(bigType)/\(smallType)"
        } else {
            return bigType.description
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let asString = try container.decode(String.self)
        if let tileType = TileType(asString) {
            self.init(bigType: tileType.bigType, smallType: tileType.smallType, orientation: tileType.orientation)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Tile type must be of the form 'word', 'word/#', or 'word/#/#'")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
    // endregion
}

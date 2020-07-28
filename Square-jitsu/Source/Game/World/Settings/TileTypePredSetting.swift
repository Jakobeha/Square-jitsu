//
// Created by Jakob Hain on 5/14/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class TileTypePredSetting: SerialSetting {
    fileprivate var pred: TileTypePred = TileTypePred()

    func decodeWellFormed(from json: JSON) throws {
        if json.string == "all" {
            pred = TileTypePred.all
        } else {
            let typePredJsons = try json.toArray()
            pred = TileTypePred()
            for typePredJson in typePredJsons {
                var typePredString = try typePredJson.toString()

                if typePredString == "all" {
                    pred.includedExceptExcluded.containsAll = true
                } else {
                    var pred1Way = pred.includedExceptExcluded
                    var isExcluded = false

                    if let negatedTypePredString = typePredString.strip(prefix: "-") {
                        typePredString = String(negatedTypePredString)
                        pred1Way = pred.excluded
                        isExcluded = true
                    }

                    if typePredString == "Solid" {
                        pred1Way.insertSolidTypes()
                    } else if let tileLayerSubstring = typePredString.strip(prefix: "Layer.") {
                        if let tileLayer = TileLayer(String(tileLayerSubstring)) {
                            pred1Way.containedLayers.insert(tileLayer)
                        } else {
                            throw DecodeSettingError.badFormat(expectedDescription: "layer")
                        }
                    } else if let tileBigType = TileBigType(typePredString) {
                        pred1Way.containedBigTypes.insert(tileBigType)
                    } else if let tileType = TileType(typePredString) {
                        pred1Way.containedTypes.insert(tileType)
                    } else {
                        throw DecodeSettingError.badFormat(expectedDescription: "layer, big-type, or type")
                    }

                    if isExcluded {
                        pred.excluded = pred1Way
                    } else {
                        pred.includedExceptExcluded = pred1Way
                    }
                }
            }
        }
    }

    func encodeWellFormed() throws -> JSON {
        if pred.containsAll {
            return JSON("all")
        } else {
            let typePredJsons: [JSON] =
                encodeWellFormed1Way(pred.includedExceptExcluded, prefix: "") +
                encodeWellFormed1Way(pred.excluded, prefix: "-")
            return JSON(typePredJsons)
        }
    }

    private func encodeWellFormed1Way(_ pred1Way: TileTypePred1Way, prefix: String) -> [JSON] {
        var typePredJsons: [JSON] = []
        for layer in pred1Way.containedLayers {
            typePredJsons.append(JSON(prefix + layer.description))
        }
        for bigType in pred1Way.containedBigTypes {
            typePredJsons.append(JSON(prefix + bigType.description))
        }
        for type in pred1Way.containedTypes {
            typePredJsons.append(JSON(prefix + type.descriptionDifferentFromBigType))
        }
        return typePredJsons
    }

    func validate() throws {}

    func decodeDynamically<T>() -> T { pred as! T }
}

extension TileTypePred: DynamicSettingCodable {
    func encodeDynamically(to setting: SerialSetting) {
        (setting as! TileTypePredSetting).pred = self
    }
}

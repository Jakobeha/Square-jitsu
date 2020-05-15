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
                let typePredString = try typePredJson.toString()
                if let tileLayerSubstring = typePredString.strip(prefix: "Layer.") {
                    if let tileLayer = TileLayer(String(tileLayerSubstring)) {
                        pred.containedLayers.insert(tileLayer)
                    } else {
                        throw DecodeSettingError.badFormat(expectedDescription: "layer")
                    }
                } else if let tileBigType = TileBigType(typePredString) {
                    pred.containedBigTypes.insert(tileBigType)
                } else if let tileType = TileType(typePredString) {
                    pred.containedTypes.insert(tileType)
                } else {
                    throw DecodeSettingError.badFormat(expectedDescription: "layer, big-type, or type")
                }
            }
        }
    }

    func encodeWellFormed() throws -> JSON {
        if pred.containsAll {
            return JSON("all")
        } else {
            var typePredJsons: [JSON] = []
            for layer in pred.containedLayers {
                typePredJsons.append(JSON(layer.description))
            }
            for bigType in pred.containedBigTypes {
                typePredJsons.append(JSON(bigType.description))
            }
            for type in pred.containedTypes {
                typePredJsons.append(JSON(type.descriptionDifferentFromBigType))
            }
            return JSON(typePredJsons)
        }
    }

    func validate() throws {}

    func decodeDynamically<T>() -> T { pred as! T }
}

extension TileTypePred: DynamicSettingCodable {
    func encodeDynamically(to setting: SerialSetting) {
        (setting as! TileTypePredSetting).pred = self
    }
}

//
// Created by Jakob Hain on 5/13/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

class CollectionSetting<Collection: StrongerCollection>: SerialSetting {
    private let newElementSetting: () -> SerialSetting

    private var elementSettings: [SerialSetting] = []

    init(newElementSetting: @escaping () -> SerialSetting) {
        self.newElementSetting = newElementSetting
    }

    func decodeWellFormed(from json: JSON) throws {
        let jsonArray = try json.toArray()
        resizeElementSettingsTo(count: jsonArray.count)
        for ((index, elementJson), elementSetting) in zip(jsonArray.enumerated(), elementSettings) {
            do {
                try elementSetting.decodeWellFormed(from: elementJson)
            } catch {
                throw DecodeSettingError.badElement(index: index, error: error)
            }
        }
    }

    func encodeWellFormed() throws -> JSON {
        JSON(try elementSettings.enumerated().map { (index, elementSetting) in
            do {
                return try elementSetting.encodeWellFormed()
            } catch {
                throw DecodeSettingError.badElement(index: index, error: error)
            }
        } as [JSON])
    }

    private func resizeElementSettingsTo(count: Int) {
        if elementSettings.count > count {
            elementSettings.removeLast(elementSettings.count - count)
        }
        while elementSettings.count < count {
            elementSettings.append(newElementSetting())
        }
    }

    func validate() throws {
        for (index, elementSetting) in elementSettings.enumerated() {
            do {
                try elementSetting.validate()
            } catch {
                throw DecodeSettingError.badElement(index: index, error: error)
            }
        }
    }

    func decodeDynamically<T>() -> T {
        let elements: [Collection.Element] = elementSettings.map { elementSetting in
            elementSetting.decodeDynamically()
        }
        let collection = Collection(elements)
        return collection as! T
    }

    func encodeDynamically(_ collection: Collection) {
        resizeElementSettingsTo(count: collection.count)
        for (elementSetting, element) in zip(elementSettings, collection) {
            (element as! DynamicSettingCodable).encodeDynamically(to: elementSetting)
        }
    }
}

extension StrongerCollection {
    func encodeDynamically(to setting: SerialSetting) {
        (setting as! CollectionSetting<Self>).encodeDynamically(self)
    }
}
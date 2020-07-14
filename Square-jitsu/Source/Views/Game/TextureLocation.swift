//
// Created by Jakob Hain on 5/14/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import SpriteKit

enum TextureLocation: Decodable, Encodable, LosslessStringConvertible {
    case builtin(name: String)
    case atUrl(URL, downloaded: UIImage)
    case embeddedUiImage(UIImage)

    static let missing: TextureLocation = .builtin(name: "Missing")

    private static let pngDataHeader: String = "data:png;base64,"

    var texture: SKTexture {
        switch self {
        case .builtin(let name):
            return SKTexture(imageNamed: name)
        case .atUrl(_, let downloaded):
            return SKTexture(image: downloaded)
        case .embeddedUiImage(let uiImage):
            return SKTexture(image: uiImage)
        }
    }

    // region decoding specific formats
    static func fromUrl(asString: String) throws -> TextureLocation {
        guard let url = URL(string: asString) else {
            throw InvalidTextureLocationError.invalidUrl(asString)
        }
        let downloaded = try TextureLocation.tryToDownloadAt(url: url)
        return .atUrl(url, downloaded: downloaded)
    }

    static func fromData(asString: String) throws -> TextureLocation {
        guard let pngDataBase64Substring = asString.strip(prefix: TextureLocation.pngDataHeader) else {
            throw InvalidTextureLocationError.unsupportedDataHeaderIn(fullText: asString)
        }
        let pngDataBase64 = String(pngDataBase64Substring)
        guard let pngData = Data(base64Encoded: pngDataBase64) else {
            throw InvalidTextureLocationError.dataNotBase64(pngDataBase64)
        }
        guard let uiImage = UIImage(data: pngData) else {
            throw InvalidTextureLocationError.invalidPngData(pngData)
        }
        return .embeddedUiImage(uiImage)
    }

    static func builtin(asString: String) throws -> TextureLocation {
        try TextureLocation.validateBuiltin(textureName: asString)
        return .builtin(name: asString)
    }
    // endregion

    // region extra validation
    private static func tryToDownloadAt(url: URL) throws -> UIImage {
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw InvalidTextureLocationError.failedToReadUrl(url, error: error)
        }
        guard let image = UIImage(data: data) else {
            throw InvalidTextureLocationError.invalidPngData(data)
        }

        return image
    }

    private static func validateBuiltin(textureName: String) throws {
        let textureExists = Bundle.main.url(forResource: textureName, withExtension: "png") != nil
        if !textureExists {
            throw InvalidTextureLocationError.namedNotFound(textureName: textureName)
        }
    }

    // region encoding and decoding
    var description: String {
        switch self {
        case .builtin(let name):
            return name
        case .atUrl(let url, downloaded: _):
            return url.description
        case .embeddedUiImage(let uiImage):
            guard let pngData = uiImage.pngData() else {
                Logger.warn("can't encode embedded texture '\(uiImage)' into PNG string for some reason")
                return TextureLocation.missing.description
            }
            let pngDataBase64 = pngData.base64EncodedString()

            return TextureLocation.pngDataHeader + pngDataBase64
        }
    }

    init(asString: String) throws {
        if let protocolEndIndex = asString.firstIndex(of: ":") {
            let `protocol` = asString[asString.startIndex..<protocolEndIndex]
            switch `protocol` {
            case "http", "https":
                self = try TextureLocation.fromUrl(asString: asString)
            case "data":
                self = try TextureLocation.fromData(asString: asString)
            default:
                throw InvalidTextureLocationError.unknownProtocol(protocol: String(`protocol`), fullText: asString)
            }
        } else {
            self = try TextureLocation.builtin(asString: asString)
        }
    }

    init?(_ description: String) {
        do {
            try self.init(asString: description)
        } catch {
            return nil
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let asString = try container.decode(String.self)
        do {
            self = try TextureLocation(asString: asString)
        } catch {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: error.localizedDescription)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
    // endregion
}

//
// Created by Jakob Hain on 7/9/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

enum InvalidTextureLocationError: Error, CustomStringConvertible {
    case unknownProtocol(protocol: String, fullText: String)
    case namedNotFound(textureName: String)
    case invalidUrl(String)
    case notHttpUrl(URL)
    case failedToReadUrl(URL, error: Error)
    case unsupportedDataHeaderIn(fullText: String)
    case dataNotBase64(String)
    case invalidPngData(Data)

    var description: String {
        switch self {
        case .unknownProtocol(let `protocol`, let fullText):
            return "unknown protocol '\(`protocol`)' parsed from: \(fullText)"
        case .namedNotFound(let textureName):
            return "builtin named texture not found: \(textureName)"
        case .invalidUrl(let urlAttempt):
            return "tried to parse as a URL but it isn't a valid one: \(urlAttempt)"
        case .notHttpUrl(let url):
            return "URL scheme must be http or https: \(url)"
        case .failedToReadUrl(let url, let error):
            return "failed to download from '\(url)': \(error.localizedDescription)"
        case .unsupportedDataHeaderIn(let fullText):
            return "unsupported data header in: \(fullText.truncatedFancy)"
        case .dataNotBase64(let dataAsString):
            return "expected data to be in base-64 format but it isn't: \(dataAsString.truncatedFancy)"
        case .invalidPngData(let data):
            return "invalid png data: \(data.base64EncodedString().truncatedFancy)"
        }
    }
}

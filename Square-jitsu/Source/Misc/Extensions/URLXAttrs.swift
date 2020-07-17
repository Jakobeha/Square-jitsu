//
// Created by Martin R. on StackOverflow
// https://stackoverflow.com/questions/38343186/write-extend-file-attributes-swift-example
// Thank you!
//

import Foundation

extension URL {
    /// Get extended attribute.
    func getExtendedAttributeDataFor(name: String) throws -> Data {
        let data = try self.withUnsafeFileSystemRepresentation { fileSystemPath -> Data in
            // Determine attribute size:
            let length = getxattr(fileSystemPath, name, nil, 0, 0, 0)
            guard length >= 0 else { throw NSError.posix(errno) }

            // Create buffer with required size:
            var data = Data(count: length)

            // Retrieve attribute:
            let result = data.withUnsafeMutableBytes { [count = data.count] in
                getxattr(fileSystemPath, name, $0.baseAddress, count, 0, 0)
            }
            guard result >= 0 else { throw NSError.posix(errno) }
            return data
        }
        return data
    }

    /// Set extended attribute.
    func setExtendedAttribute(data: Data, name: String) throws {
        try self.withUnsafeFileSystemRepresentation { fileSystemPath in
            let result = data.withUnsafeBytes {
                setxattr(fileSystemPath, name, $0.baseAddress, data.count, 0, 0)
            }

            guard result >= 0 else { throw NSError.posix(errno) }
        }
    }

    /// Remove extended attribute.
    func removeExtendedAttributeFor(name: String) throws {
        try self.withUnsafeFileSystemRepresentation { fileSystemPath in
            let result = removexattr(fileSystemPath, name, 0)
            guard result >= 0 else { throw NSError.posix(errno) }
        }
    }

    /// Get list of all extended attributes.
    func listExtendedAttributes() throws -> [String] {
        let list = try self.withUnsafeFileSystemRepresentation { fileSystemPath -> [String] in
            let length = listxattr(fileSystemPath, nil, 0, 0)
            guard length >= 0 else { throw NSError.posix(errno) }

            // Create buffer with required size:
            var nameBuffer = Array<CChar>(repeating: 0, count: length)

            // Retrieve attribute list:
            let result = listxattr(fileSystemPath, &nameBuffer, nameBuffer.count, 0)
            guard result >= 0 else { throw NSError.posix(errno) }

            // Extract attribute names:
            let list = nameBuffer.split(separator: 0).compactMap {
                $0.withUnsafeBufferPointer {
                    $0.withMemoryRebound(to: UInt8.self) {
                        String(bytes: $0, encoding: .utf8)
                    }
                }
            }
            return list
        }
        return list
    }
}
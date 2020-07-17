//
// Created by Jakob Hain on 7/16/20.
// Copyright (c) 2020 Jakobeha. All rights reserved.
//

import Foundation

extension NSError {
    /// Returns an error conforming to `Error` (unlike `POSIXError`) for the given unix error code
    static func posix(_ errno: Int32) -> NSError {
        NSError(
            domain: NSPOSIXErrorDomain,
            code: Int(errno),
            userInfo: [NSLocalizedDescriptionKey: String(cString: strerror(errno))]
        )
    }
}

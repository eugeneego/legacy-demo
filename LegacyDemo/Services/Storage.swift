//
// Storage
// LegacyDemo
//
// Created by Eugene Egorov on 05 September 2018.
// Copyright (c) 2018 Eugene Egorov. All rights reserved.
//

import Foundation

public struct Storage {
    public static var libraryDirectory: URL {
        FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
    }

    public static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    public static var cachesDirectory: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }

    public static var tempDirectory: URL {
        URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    }

    public static func createDirectory(url: URL) {
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    }

    public static func relativePath(from: URL, to: URL) -> String {
        let basePath = from.path
        var path = to.path
        if let range = path.range(of: basePath) {
            path = String(path[range.upperBound...])
        }
        return path
    }

    public static let libraryScheme: String = "library"
    public static let documentsScheme: String = "documents"
    public static let cachesScheme: String = "cache"

    public static let schemeDirectories: [String: URL] = [
        libraryScheme: libraryDirectory,
        documentsScheme: documentsDirectory,
        cachesScheme: cachesDirectory,
    ]
}

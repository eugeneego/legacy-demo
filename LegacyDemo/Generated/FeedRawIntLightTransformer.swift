// Generated using Sourcery 0.16.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import Legacy

// swiftlint:disable all
struct FeedRawIntLightTransformer: LightTransformer {
    typealias T = Feed.RawInt

    private let transformer = NumberLightTransformer<Int>()

    func from(any value: Any?) -> T? {
        guard let rawValue = transformer.from(any: value) else { return nil }

        switch rawValue {
            case 1:
                return .one
            case 3:
                return .three
            case 5:
                return .five
            default:
                return nil
        }
    }

    func to(any value: T?) -> Any? {
        guard let value = value else { return nil }

        switch value {
            case .one:
                return transformer.to(any: 1)
            case .three:
                return transformer.to(any: 3)
            case .five:
                return transformer.to(any: 5)
        }
    }
}

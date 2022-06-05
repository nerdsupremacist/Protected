
import Foundation

@dynamicMemberLookup
public struct ReadOnly<ProtectedType>: RightsManifest {
    public init() { }

    public subscript<T>(dynamicMember keyPath: KeyPath<ProtectedType, T>) -> ReadPropertyRight<ProtectedType, T, Protected<T, ReadOnly<T>>> {
        return ReadPropertyRight(keyPath).protected(by: .readOnly())
    }
}

extension RightsManifest {
    static func readOnly<T>() -> ReadOnly<T> where Self == ReadOnly<T> {
        return ReadOnly()
    }
}

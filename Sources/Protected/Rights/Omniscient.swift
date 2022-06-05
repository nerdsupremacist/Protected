
import Foundation

@dynamicMemberLookup
public struct Omniscient<ProtectedType> : RightsManifest {
    public init() { }

    public subscript<T>(dynamicMember keyPath: KeyPath<ProtectedType, T>) -> ReadPropertyRight<ProtectedType, T, T> {
        return ReadPropertyRight(keyPath)
    }

    public subscript<T>(dynamicMember keyPath: WritableKeyPath<ProtectedType, T>) -> WritePropertyRight<ProtectedType, T> {
        return WritePropertyRight(keyPath)
    }
}

extension RightsManifest {
    static func omniscient<T>() -> Omniscient<T> where Self == Omniscient<T> {
        return Omniscient()
    }
}

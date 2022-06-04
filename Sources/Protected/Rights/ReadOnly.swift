
import Foundation

@dynamicMemberLookup
public struct ReadOnly<ProtectedType>: RightsManifest {
    public init() { }

    public subscript<T>(dynamicMember keyPath: KeyPath<ProtectedType, T>) -> ReadPropertyRight<ProtectedType, T, ProtectedRightResolutionStrategy<ReadOnly<T>>> {
        return ReadPropertyRight(keyPath, protectedBy: ReadOnly<T>())
    }
}

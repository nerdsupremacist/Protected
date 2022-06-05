
import Foundation

public struct ProtectedRightResolutionStrategy<Rights: RightsManifest>: RightResolutionStrategy {
    public typealias Value = Rights.ProtectedType
    public typealias Resolved = Protected<Value, Rights>

    private let rights: Rights

    init(rights: Rights) {
        self.rights = rights
    }

    public func resolve(value: Rights.ProtectedType) -> Protected<Value, Rights> {
        return Protected(value, by: rights)
    }
}

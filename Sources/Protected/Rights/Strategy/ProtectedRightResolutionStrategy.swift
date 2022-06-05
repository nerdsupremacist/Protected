
import Foundation

struct ProtectedRightResolutionStrategy<Rights: RightsManifest>: RightResolutionStrategy {
    typealias Value = Rights.ProtectedType
    typealias Resolved = Protected<Value, Rights>

    private let rights: Rights

    init(rights: Rights) {
        self.rights = rights
    }

    func resolve(value: Rights.ProtectedType) -> Protected<Value, Rights> {
        return Protected(value, by: rights)
    }
}

extension AnyRightResolutionStrategy {

    static func protected<Rights: RightsManifest>(_ rights: Rights) -> AnyRightResolutionStrategy<Value, Resolved> where Rights.ProtectedType == Value, Resolved == Rights.Resolved {
        return AnyRightResolutionStrategy(ProtectedRightResolutionStrategy(rights: rights))
    }

}

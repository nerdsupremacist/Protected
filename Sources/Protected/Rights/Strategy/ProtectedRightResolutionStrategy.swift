
import Foundation

struct ProtectedRightResolutionStrategy<Strategy: RightResolutionStrategy, Rights: RightsManifest>: RightResolutionStrategy where Rights.ProtectedType == Strategy.Resolved {
    typealias Value = Strategy.Value
    typealias Resolved = Protected<Strategy.Resolved, Rights>

    private let strategy: Strategy
    private let rights: Rights

    init(strategy: Strategy, rights: Rights) {
        self.strategy = strategy
        self.rights = rights
    }

    func resolve(value: Value) -> Protected<Strategy.Resolved, Rights> {
        return Protected(strategy.resolve(value: value), by: rights)
    }
}

extension RightResolutionStrategy {

    func protected<Rights: RightsManifest>(by rights: Rights) -> ProtectedRightResolutionStrategy<Self, Rights> where Rights.ProtectedType == Resolved {
        return ProtectedRightResolutionStrategy(strategy: self, rights: rights)
    }

}

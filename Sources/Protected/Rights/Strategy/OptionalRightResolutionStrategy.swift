
import Foundation

struct OptionalRightResolutionStrategy<Strategy : RightResolutionStrategy>: RightResolutionStrategy {
    typealias Value = Strategy.Value?
    typealias Resolved = Strategy.Resolved?

    let strategy: Strategy

    init(strategy: Strategy) {
        self.strategy = strategy
    }

    public func resolve(value: Value) -> Resolved {
        return value.map { strategy.resolve(value: $0) }
    }
}

extension RightResolutionStrategy {

    func optional() -> OptionalRightResolutionStrategy<Self> {
        return OptionalRightResolutionStrategy(strategy: self)
    }

}

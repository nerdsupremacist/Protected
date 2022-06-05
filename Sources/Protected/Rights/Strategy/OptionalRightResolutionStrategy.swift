
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

extension AnyRightResolutionStrategy {

    static func optional<V, R>(_ strategy: AnyRightResolutionStrategy<V, R>) -> AnyRightResolutionStrategy<Value, Resolved> where Value == V?, Resolved == R? {
        return AnyRightResolutionStrategy(OptionalRightResolutionStrategy(strategy: strategy))
    }

}

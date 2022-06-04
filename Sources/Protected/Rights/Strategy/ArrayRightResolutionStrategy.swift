
import Foundation

public struct ArrayRightResolutionStrategy<Strategy : RightResolutionStrategy>: RightResolutionStrategy {
    public typealias Value = [Strategy.Value]
    public typealias Resolved = [Strategy.Resolved]

    let strategy: Strategy

    init(strategy: Strategy) {
        self.strategy = strategy
    }

    public func resolve(value: Value) -> Resolved {
        return value.map { strategy.resolve(value: $0) }
    }
}

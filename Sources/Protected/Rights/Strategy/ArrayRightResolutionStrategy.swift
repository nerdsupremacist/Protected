
import Foundation

struct ArrayRightResolutionStrategy<Strategy : RightResolutionStrategy>: RightResolutionStrategy {
    typealias Value = [Strategy.Value]
    typealias Resolved = [Strategy.Resolved]

    let strategy: Strategy

    init(strategy: Strategy) {
        self.strategy = strategy
    }

    func resolve(value: Value) -> Resolved {
        return value.map { strategy.resolve(value: $0) }
    }
}

extension RightResolutionStrategy {

    func array() -> ArrayRightResolutionStrategy<Self> {
        return ArrayRightResolutionStrategy(strategy: self)
    }

}

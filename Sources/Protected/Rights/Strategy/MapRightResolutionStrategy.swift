
import Foundation

class MapRightResolutionResolutionStrategy<Value, Strategy: RightResolutionStrategy, Resolved>: RightResolutionStrategy where Strategy.Value == Value {
    private let strategy: Strategy
    private let transform: (Strategy.Resolved) -> Resolved

    init(strategy: Strategy, transform: @escaping (Strategy.Resolved) -> Resolved) {
        self.strategy = strategy
        self.transform = transform
    }

    func resolve(value: Value) -> Resolved {
        return transform(strategy.resolve(value: value))
    }
}

extension RightResolutionStrategy {

    func map<T>(_ transform: @escaping (Resolved) -> T) -> MapRightResolutionResolutionStrategy<Value, Self, T> {
        return MapRightResolutionResolutionStrategy(strategy: self, transform: transform)
    }

}

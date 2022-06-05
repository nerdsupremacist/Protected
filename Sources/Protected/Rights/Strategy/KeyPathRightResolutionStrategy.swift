
import Foundation

struct KeyPathRightResolutionStrategy<Strategy: RightResolutionStrategy, Resolved>: RightResolutionStrategy {
    private let strategy: Strategy
    private let keyPath: KeyPath<Strategy.Resolved, Resolved>

    init(strategy: Strategy, keyPath: KeyPath<Strategy.Resolved, Resolved>) {
        self.strategy = strategy
        self.keyPath = keyPath
    }

    func resolve(value: Strategy.Value) -> Resolved {
        return strategy.resolve(value: value)[keyPath: keyPath]
    }
}

extension RightResolutionStrategy {

    func keyPath<T>(_ keyPath: KeyPath<Resolved, T>) -> KeyPathRightResolutionStrategy<Self, T> {
        return KeyPathRightResolutionStrategy(strategy: self, keyPath: keyPath)
    }

}

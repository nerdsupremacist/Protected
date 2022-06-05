
import Foundation

final class AnyRightResolutionStrategy<Value, Resolved>: RightResolutionStrategy {
    private class BaseStorage {
        func resolve(value: Value) -> Resolved {
            fatalError()
        }
    }

    private class Storage<Strategy: RightResolutionStrategy>: BaseStorage where Strategy.Value == Value, Strategy.Resolved == Resolved {
        private let strategy: Strategy

        init(strategy: Strategy) {
            self.strategy = strategy
        }

        override func resolve(value: Value) -> Resolved {
            return strategy.resolve(value: value)
        }
    }

    private let storage: BaseStorage

    init<Strategy: RightResolutionStrategy>(_ strategy: Strategy) where Strategy.Value == Value, Strategy.Resolved == Resolved {
        self.storage = Storage(strategy: strategy)
    }

    func resolve(value: Value) -> Resolved {
        return storage.resolve(value: value)
    }
}

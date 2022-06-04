
import Foundation

public struct ReadPropertyRight<ProtectedType, Value, Strategy: RightResolutionStrategy> where Strategy.Value == Value {
    let keyPath: KeyPath<ProtectedType, Value>
    let strategy: Strategy

    init(_ keyPath: KeyPath<ProtectedType, Value>, strategy: Strategy) {
        self.keyPath = keyPath
        self.strategy = strategy
    }

}


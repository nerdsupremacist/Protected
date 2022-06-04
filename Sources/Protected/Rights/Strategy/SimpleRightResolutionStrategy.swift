
import Foundation

public struct SimpleRightResolutionStrategy<Value>: RightResolutionStrategy {
    init() { }

    public func resolve(value: Value) -> Value {
        return value
    }
}

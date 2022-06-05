
import Foundation

struct SimpleRightResolutionStrategy<Value>: RightResolutionStrategy {
    init() { }

    func resolve(value: Value) -> Value {
        return value
    }
}

extension AnyRightResolutionStrategy where Value == Resolved {
    static func simple() -> AnyRightResolutionStrategy<Value, Resolved> {
        return AnyRightResolutionStrategy(SimpleRightResolutionStrategy())
    }
}

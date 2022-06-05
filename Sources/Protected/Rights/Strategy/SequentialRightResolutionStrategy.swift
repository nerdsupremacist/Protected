
import Foundation

struct SequentialRightResolutionStrategy<Previous: RightResolutionStrategy, Next: RightResolutionStrategy>: RightResolutionStrategy where Previous.Resolved == Next.Value {
    let previous: Previous
    let next: Next

    func resolve(value: Previous.Value) -> Next.Resolved {
        return next.resolve(value: previous.resolve(value: value))
    }
}

extension RightResolutionStrategy {

    func wrapAsSimple<T, S>(_ create: (SimpleRightResolutionStrategy<T>) -> S) -> SequentialRightResolutionStrategy<Self, S> where S.Value == Resolved {
        let simple = SimpleRightResolutionStrategy<T>()
        return SequentialRightResolutionStrategy(previous: self, next: create(simple))
    }

}

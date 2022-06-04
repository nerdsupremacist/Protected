
import Foundation

public protocol RightResolutionStrategy {
    associatedtype Value
    associatedtype Resolved

    func resolve(value: Value) -> Resolved
}


import Foundation

@dynamicMemberLookup
public struct ReadPropertyRight<ProtectedType, Value> {
    let strategy: AnyRightResolutionStrategy<ProtectedType, Value>

    init<Strategy: RightResolutionStrategy>(strategy: Strategy) where Strategy.Value == ProtectedType, Strategy.Resolved == Value {
        self.strategy = AnyRightResolutionStrategy(strategy)
    }

    init<Strategy: RightResolutionStrategy>(strategy: (SimpleRightResolutionStrategy<ProtectedType>) -> Strategy) where Strategy.Value == ProtectedType, Strategy.Resolved == Value {
        self.init(strategy: strategy(SimpleRightResolutionStrategy()))
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<Value, T>) -> ReadPropertyRight<ProtectedType, T> {
        return .init(strategy: strategy.keyPath(keyPath))
    }
}

extension ReadPropertyRight {
    public init(_ keyPath: KeyPath<ProtectedType, Value>) {
        self.init { $0.keyPath(keyPath) }
    }

    public init(_ transform: @escaping (ProtectedType) -> Value) {
        self.init { $0.map(transform) }
    }
}

extension ReadPropertyRight {
    public func protected<Rights : RightsManifest>(by rights: Rights) -> ReadPropertyRight<ProtectedType, Rights.Resolved> where Value == Rights.ProtectedType {
        return .init(strategy: strategy.protected(by: rights))
    }
    
    public func protected<Rights : RightsManifest>(by rights: Rights) -> ReadPropertyRight<ProtectedType, Rights.Resolved?> where Value == Rights.ProtectedType? {
        return wrapResult { $0.protected(by: rights).optional() }
    }

    public func protected<Rights : RightsManifest>(by rights: Rights) -> ReadPropertyRight<ProtectedType, [Rights.Resolved]> where Value == [Rights.ProtectedType] {
        return wrapResult { $0.protected(by: rights).array() }
    }

    public func protected<Rights : RightsManifest>(by rights: Rights) -> ReadPropertyRight<ProtectedType, [Rights.Resolved]?> where Value == [Rights.ProtectedType]? {
        return wrapResult { $0.protected(by: rights).array().optional() }
    }

    public func protected<Rights : RightsManifest>(by rights: Rights) -> ReadPropertyRight<ProtectedType, [Rights.Resolved?]> where Value == [Rights.ProtectedType?] {
        return wrapResult { $0.protected(by: rights).optional().array() }
    }

    public func protected<Rights : RightsManifest>(by rights: Rights) -> ReadPropertyRight<ProtectedType, [Rights.Resolved?]?> where Value == [Rights.ProtectedType?]? {
        return wrapResult { $0.protected(by: rights).optional().array().optional() }
    }

    private func wrapResult<T, S: RightResolutionStrategy>(_ create: (SimpleRightResolutionStrategy<T>) -> S) -> ReadPropertyRight<ProtectedType, S.Resolved> where Value == S.Value {
        return .init(strategy: strategy.wrapResult(create))
    }
}

extension ReadPropertyRight {
    public subscript<T : RightsManifest>(dynamicMember keyPath: KeyPath<Rights<T.ProtectedType>, T>) -> ReadPropertyRight<ProtectedType, T.Resolved> where Value == T.ProtectedType {
        return protected(by: Rights.shared[keyPath: keyPath])
    }

    public subscript<T : RightsManifest>(dynamicMember keyPath: KeyPath<Rights<T.ProtectedType>, T>) -> BuiltReadPropertyRight<ProtectedType, T.Resolved?> where Value == T.ProtectedType? {
        return BuiltReadPropertyRight(right: protected(by: Rights.shared[keyPath: keyPath]))
    }

    public subscript<T : RightsManifest>(dynamicMember keyPath: KeyPath<Rights<T.ProtectedType>, T>) -> BuiltReadPropertyRight<ProtectedType, [T.Resolved]> where Value == [T.ProtectedType] {
        return BuiltReadPropertyRight(right: protected(by: Rights.shared[keyPath: keyPath]))
    }

    public subscript<T : RightsManifest>(dynamicMember keyPath: KeyPath<Rights<T.ProtectedType>, T>) -> BuiltReadPropertyRight<ProtectedType, [T.Resolved]?> where Value == [T.ProtectedType]? {
        return BuiltReadPropertyRight(right: protected(by: Rights.shared[keyPath: keyPath]))
    }

    public subscript<T : RightsManifest>(dynamicMember keyPath: KeyPath<Rights<T.ProtectedType>, T>) -> BuiltReadPropertyRight<ProtectedType, [T.Resolved?]> where Value == [T.ProtectedType?] {
        return BuiltReadPropertyRight(right: protected(by: Rights.shared[keyPath: keyPath]))
    }

    public subscript<T : RightsManifest>(dynamicMember keyPath: KeyPath<Rights<T.ProtectedType>, T>) -> BuiltReadPropertyRight<ProtectedType, [T.Resolved?]?> where Value == [T.ProtectedType?]? {
        return BuiltReadPropertyRight(right: protected(by: Rights.shared[keyPath: keyPath]))
    }
}

public struct BuiltReadPropertyRight<ProtectedType, Value> {
    private let right: ReadPropertyRight<ProtectedType, Value>

    fileprivate init(right: ReadPropertyRight<ProtectedType, Value>) {
        self.right = right
    }

    public func callAsFunction() -> ReadPropertyRight<ProtectedType, Value> {
        return right
    }
}

extension ReadPropertyRight {

    public func map<T>(_ transform: @escaping (Value) -> T) -> ReadPropertyRight<ProtectedType, T> {
        return .init(strategy: strategy.map(transform))
    }

}

public func ??<ProtectedType, T>(_ lhs: ReadPropertyRight<ProtectedType, T?>, _ rhs: @autoclosure @escaping () -> T?) -> ReadPropertyRight<ProtectedType, T?> {
    return lhs.map { $0 ?? rhs() }
}

public func ??<ProtectedType, T>(_ lhs: ReadPropertyRight<ProtectedType, T?>, _ rhs: @autoclosure @escaping () -> T) -> ReadPropertyRight<ProtectedType, T> {
    return lhs.map { $0 ?? rhs() }
}

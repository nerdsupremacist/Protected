
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
        return wrapAsSimple { $0.protected(by: rights).optional() }
    }

    public func protected<Rights : RightsManifest>(by rights: Rights) -> ReadPropertyRight<ProtectedType, [Rights.Resolved]> where Value == [Rights.ProtectedType] {
        return wrapAsSimple { $0.protected(by: rights).array() }
    }

    public func protected<Rights : RightsManifest>(by rights: Rights) -> ReadPropertyRight<ProtectedType, [Rights.Resolved]?> where Value == [Rights.ProtectedType]? {
        return wrapAsSimple { $0.protected(by: rights).array().optional() }
    }

    public func protected<Rights : RightsManifest>(by rights: Rights) -> ReadPropertyRight<ProtectedType, [Rights.Resolved?]> where Value == [Rights.ProtectedType?] {
        return wrapAsSimple { $0.protected(by: rights).optional().array() }
    }

    public func protected<Rights : RightsManifest>(by rights: Rights) -> ReadPropertyRight<ProtectedType, [Rights.Resolved?]?> where Value == [Rights.ProtectedType?]? {
        return wrapAsSimple { $0.protected(by: rights).optional().array().optional() }
    }

    private func wrapAsSimple<T, S: RightResolutionStrategy>(_ create: (SimpleRightResolutionStrategy<T>) -> S) -> ReadPropertyRight<ProtectedType, S.Resolved> where Value == S.Value {
        return .init(strategy: strategy.wrapAsSimple(create))
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


import Foundation

public struct ReadPropertyRight<ProtectedType, Value, Resolved> {
    let keyPath: KeyPath<ProtectedType, Value>
    let strategy: AnyRightResolutionStrategy<Value, Resolved>

    init<Strategy: RightResolutionStrategy>(_ keyPath: KeyPath<ProtectedType, Value>, strategy: Strategy) where Strategy.Value == Value, Strategy.Resolved == Resolved {
        self.keyPath = keyPath
        self.strategy = AnyRightResolutionStrategy(strategy)
    }
}

extension ReadPropertyRight where Resolved == Value {
    public init(_ keyPath: KeyPath<ProtectedType, Value>) {
        self.init(keyPath, strategy: SimpleRightResolutionStrategy())
    }
}

extension ReadPropertyRight {
    public func protected<Rights : RightsManifest>(by rights: Rights) -> ReadPropertyRight<ProtectedType, Value, Rights.Resolved> where Resolved == Rights.ProtectedType {
        return .init(keyPath, strategy: strategy.protected(by: rights))
    }
    
    public func protected<Rights : RightsManifest>(by rights: Rights) -> ReadPropertyRight<ProtectedType, Value, Rights.Resolved?> where Resolved == Rights.ProtectedType? {
        return wrapAsSimple { $0.protected(by: rights).optional() }
    }

    public func protected<Rights : RightsManifest>(by rights: Rights) -> ReadPropertyRight<ProtectedType, Value, [Rights.Resolved]> where Resolved == [Rights.ProtectedType] {
        return wrapAsSimple { $0.protected(by: rights).array() }
    }

    public func protected<Rights : RightsManifest>(by rights: Rights) -> ReadPropertyRight<ProtectedType, Value, [Rights.Resolved]?> where Resolved == [Rights.ProtectedType]? {
        return wrapAsSimple { $0.protected(by: rights).array().optional() }
    }

    public func protected<Rights : RightsManifest>(by rights: Rights) -> ReadPropertyRight<ProtectedType, Value, [Rights.Resolved?]> where Resolved == [Rights.ProtectedType?] {
        return wrapAsSimple { $0.protected(by: rights).optional().array() }
    }

    public func protected<Rights : RightsManifest>(by rights: Rights) -> ReadPropertyRight<ProtectedType, Value, [Rights.Resolved?]?> where Resolved == [Rights.ProtectedType?]? {
        return wrapAsSimple { $0.protected(by: rights).optional().array().optional() }
    }

    private func wrapAsSimple<T, S: RightResolutionStrategy>(_ create: (SimpleRightResolutionStrategy<T>) -> S) -> ReadPropertyRight<ProtectedType, Value, S.Resolved> where S.Value == Resolved {

        return .init(keyPath, strategy: strategy.wrapAsSimple(create))
    }
}

extension ReadPropertyRight {

    public func map<T>(_ transform: @escaping (Resolved) -> T) -> ReadPropertyRight<ProtectedType, Value, T> {
        return .init(keyPath, strategy: strategy.map(transform))
    }

}

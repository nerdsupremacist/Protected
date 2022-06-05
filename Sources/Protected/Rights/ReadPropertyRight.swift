
import Foundation

public struct ReadPropertyRight<ProtectedType, Value, Resolved> {
    let keyPath: KeyPath<ProtectedType, Value>
    let strategy: AnyRightResolutionStrategy<Value, Resolved>

    init(_ keyPath: KeyPath<ProtectedType, Value>, strategy: AnyRightResolutionStrategy<Value, Resolved>) {
        self.keyPath = keyPath
        self.strategy = AnyRightResolutionStrategy(strategy)
    }
}

extension ReadPropertyRight where Resolved == Value {
    public init(_ keyPath: KeyPath<ProtectedType, Value>) {
        self.init(keyPath, strategy: .simple())
    }

    public func protected<Rights : RightsManifest>(by rights: Rights) -> ReadPropertyRight<ProtectedType, Value, Rights.Resolved> where Value == Rights.ProtectedType {
        return .init(keyPath, strategy: .protected(rights))
    }

    public func protected<Rights : RightsManifest>(by rights: Rights) -> ReadPropertyRight<ProtectedType, Value, Rights.Resolved?> where Value == Rights.ProtectedType? {
        return .init(keyPath, strategy: .optional(.protected(rights)))
    }

    public func protected<Rights : RightsManifest>(by rights: Rights) -> ReadPropertyRight<ProtectedType, Value, [Rights.Resolved]> where Value == [Rights.ProtectedType] {
        return .init(keyPath, strategy: .array(.protected(rights)))
    }

    public func protected<Rights : RightsManifest>(by rights: Rights) -> ReadPropertyRight<ProtectedType, Value, [Rights.Resolved]?> where Value == [Rights.ProtectedType]? {
        return .init(keyPath, strategy: .optional(.array(.protected(rights))))
    }

    public func protected<Rights : RightsManifest>(by rights: Rights) -> ReadPropertyRight<ProtectedType, Value, [Rights.Resolved?]> where Value == [Rights.ProtectedType?] {
        return .init(keyPath, strategy: .array(.optional(.protected(rights))))
    }

    public func protected<Rights : RightsManifest>(by rights: Rights) -> ReadPropertyRight<ProtectedType, Value, [Rights.Resolved?]?> where Value == [Rights.ProtectedType?]? {
        return .init(keyPath, strategy: .optional(.array(.optional(.protected(rights)))))
    }

}

extension ReadPropertyRight {
    public init<Rights : RightsManifest>(_ keyPath: KeyPath<ProtectedType, Value>,
                                         protectedBy rights: Rights) where Resolved == [Rights.Resolved]?, Value == [Rights.ProtectedType]? {

        self.init(keyPath, strategy: .optional(.array(.protected(rights))))
    }

    public init<Rights : RightsManifest>(_ keyPath: KeyPath<ProtectedType, Value>,
                                         protectedBy rights: Rights) where Resolved == [Rights.Resolved?], Value == [Rights.ProtectedType?] {

        self.init(keyPath, strategy: .array(.optional(.protected(rights))))
    }

    public init<Rights : RightsManifest>(_ keyPath: KeyPath<ProtectedType, Value>,
                                         protectedBy rights: Rights) where Resolved == [Rights.Resolved?]?, Value == [Rights.ProtectedType?]? {

        self.init(keyPath, strategy: .optional(.array(.optional(.protected(rights)))))
    }
}

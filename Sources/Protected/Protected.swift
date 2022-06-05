
import Foundation

@dynamicMemberLookup
public class Protected<Value, Rights : RightsManifest> where Rights.ProtectedType == Value {
    private var value: Value
    private let rights: Rights

    public init(_ value: Value, by rights: Rights) {
        self.value = value
        self.rights = rights
    }

    public subscript<T, Resolved>(dynamicMember keyPath: KeyPath<Rights, ReadPropertyRight<Value, T, Resolved>>) -> Resolved {
        let right = rights[keyPath: keyPath]
        return right.strategy.resolve(value: value[keyPath: right.keyPath])
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<Rights, WritePropertyRight<Value, T>>) -> T {
        get {
            return value[keyPath: rights[keyPath: keyPath].keyPath]
        }
        set {
            value[keyPath: rights[keyPath: keyPath].keyPath] = newValue
        }
    }

    public func unsafeChangeRights<TransformedRights : RightsManifest>(to rights: TransformedRights) -> Protected<Value, TransformedRights> {
        return Protected<Value, TransformedRights>(value, by: rights)
    }

    public func unsafeBypassRights() -> Value {
        return value
    }
}

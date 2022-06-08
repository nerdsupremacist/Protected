
import Foundation

@dynamicMemberLookup
public final class Protected<Value, Rights : RightsManifest> where Rights.ProtectedType == Value {
    private var value: Value
    private let rights: Rights

    public init(_ value: Value, by rights: Rights) {
        self.value = value
        self.rights = rights
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<Rights, ReadPropertyRight<Value, T>>) -> T {
        let right = rights[keyPath: keyPath]
        return right.strategy.resolve(value: value)
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<Rights, WritePropertyRight<Value, T>>) -> T {
        get {
            return value[keyPath: rights[keyPath: keyPath].keyPath]
        }
        set {
            value[keyPath: rights[keyPath: keyPath].keyPath] = newValue
        }
    }

    public func unsafeMutate(_ mutations: (inout Value) throws -> Void) rethrows {
        try mutations(&value)
    }

    public func unsafeChangeRights<TransformedRights : RightsManifest>(to rights: TransformedRights) -> Protected<Value, TransformedRights> {
        return Protected<Value, TransformedRights>(value, by: rights)
    }

    public func unsafeMapAndChangeRights<TransformedRights : RightsManifest>(to rights: TransformedRights, _ transform: (Value) throws -> Value) rethrows -> Protected<Value, TransformedRights> {
        let value = try transform(value)
        return Protected<Value, TransformedRights>(value, by: rights)
    }

    public func unsafeMutateAndChangeRights<TransformedRights : RightsManifest>(to rights: TransformedRights,
                                                                                _ mutations: (inout Value) throws -> Void) rethrows -> Protected<Value, TransformedRights> {

        try unsafeMutate(mutations)
        return unsafeChangeRights(to: rights)
    }

    public func unsafeBypassRights() -> Value {
        return value
    }

    public func unsafeChange() -> ProtectedBuilder<Value> {
        return ProtectedBuilder(self)
    }
}

extension Protected where Rights == Omniscient<Value> {
    public convenience init(_ value: Value) {
        self.init(value, by: .omniscient())
    }
}

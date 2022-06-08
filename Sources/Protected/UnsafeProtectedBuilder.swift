
import Foundation

public func protect<Value>(_ value: Value) -> ProtectedBuilder<Value> {
    return ProtectedBuilder(value)
}

@dynamicMemberLookup
public struct ProtectedBuilder<Value> {
    private class BaseStorage {
        func mutate(_ mutations: (inout Value) throws -> Void) rethrows {
            fatalError()
        }

        func map(_ mutations: (Value) throws -> Value) rethrows -> BaseStorage {
            fatalError()
        }

        func protected<T: RightsManifest>(by rights: T) -> Protected<Value, T> {
            fatalError()
        }
    }

    private final class ProtectedStorage<Rights: RightsManifest>: BaseStorage where Rights.ProtectedType == Value {
        private let protected: Protected<Value, Rights>

        init(_ protected: Protected<Value, Rights>) {
            self.protected = protected
        }

        override func mutate(_ mutations: (inout Value) throws -> Void) rethrows {
            try protected.unsafeMutate(mutations)
        }

        override func map(_ mutations: (Value) throws -> Value) rethrows -> BaseStorage {
            return ValueStorage(try mutations(protected.unsafeBypassRights()))
        }

        override func protected<T: RightsManifest>(by rights: T) -> Protected<Value, T> {
            if T.self == Rights.self {
                return protected as! Protected<Value, T>
            }

            return Protected(protected.unsafeBypassRights(), by: rights)
        }
    }

    private final class ValueStorage: BaseStorage {
        private var _value: Value

        init(_ value: Value) {
            self._value = value
        }

        override func mutate(_ mutations: (inout Value) throws -> Void) rethrows {
            try mutations(&_value)
        }

        override func map(_ mutations: (Value) throws -> Value) rethrows -> BaseStorage {
            return ValueStorage(try mutations(_value))
        }

        override func protected<T: RightsManifest>(by rights: T) -> Protected<Value, T> {
            return Protected(_value, by: rights)
        }
    }

    private let storage: BaseStorage

    private init(_ storage: BaseStorage) {
        self.storage = storage
    }

    fileprivate init(_ value: Value) {
        self.init(ValueStorage(value))
    }

    init<Rights: RightsManifest>(_ protected: Protected<Value, Rights>) where Rights.ProtectedType == Value {
        self.init(ProtectedStorage(protected))
    }

    public func mutate(_ mutations: (inout Value) throws -> Void) rethrows -> ProtectedBuilder<Value> {
        try storage.mutate(mutations)
        return self
    }

    public func map(_ mutations: (Value) throws -> Value) rethrows -> ProtectedBuilder<Value> {
        return ProtectedBuilder(try storage.map(mutations))
    }

    public func with<Rights: RightsManifest>(rights: Rights) -> Protected<Value, Rights> where Rights.ProtectedType == Value {
        return storage.protected(by: rights)
    }

    public subscript<T : RightsManifest>(dynamicMember keyPath: KeyPath<Rights<Value>, T>) -> BuiltProtectedCallable<Value, T> where T.ProtectedType == Value {
        return BuiltProtectedCallable(builder: self, rights: Rights.shared[keyPath: keyPath])
    }
}

public struct BuiltProtectedCallable<Value, Rights: RightsManifest> where Rights.ProtectedType == Value {
    private let builder: ProtectedBuilder<Value>
    private let rights: Rights

    fileprivate init(builder: ProtectedBuilder<Value>, rights: Rights) {
        self.builder = builder
        self.rights = rights
    }

    public func callAsFunction() -> Protected<Value, Rights> {
        return builder.with(rights: rights)
    }
}

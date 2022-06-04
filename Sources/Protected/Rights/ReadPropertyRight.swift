
import Foundation

public struct ReadPropertyRight<ProtectedType, Value, Strategy: RightResolutionStrategy> where Strategy.Value == Value {
    let keyPath: KeyPath<ProtectedType, Value>
    let strategy: Strategy

    init(_ keyPath: KeyPath<ProtectedType, Value>, strategy: Strategy) {
        self.keyPath = keyPath
        self.strategy = strategy
    }

    public init<Rights : RightsManifest>(_ keyPath: KeyPath<ProtectedType, Value>,
                                         protectedBy rights: Rights) where Rights.ProtectedType == Value, Strategy == ProtectedRightResolutionStrategy<Rights> {

        self.init(keyPath, strategy: ProtectedRightResolutionStrategy(rights: rights))
    }

    public init<Rights : RightsManifest>(_ keyPath: KeyPath<ProtectedType, Value>,
                                         protectedBy rights: Rights) where Optional<Rights.ProtectedType> == Value, Strategy == OptionalRightResolutionStrategy<ProtectedRightResolutionStrategy<Rights>> {

        self.init(keyPath, strategy: OptionalRightResolutionStrategy(strategy: ProtectedRightResolutionStrategy(rights: rights)))
    }

    public init<Rights : RightsManifest>(_ keyPath: KeyPath<ProtectedType, Value>,
                                         protectedBy rights: Rights) where Array<Rights.ProtectedType> == Value, Strategy == ArrayRightResolutionStrategy<ProtectedRightResolutionStrategy<Rights>> {

        self.init(keyPath, strategy: ArrayRightResolutionStrategy(strategy: ProtectedRightResolutionStrategy(rights: rights)))
    }

    public init<Rights : RightsManifest>(_ keyPath: KeyPath<ProtectedType, Value>,
                                         protectedBy rights: Rights) where Optional<Array<Rights.ProtectedType>> == Value, Strategy == OptionalRightResolutionStrategy<ArrayRightResolutionStrategy<ProtectedRightResolutionStrategy<Rights>>> {

        self.init(keyPath, strategy: OptionalRightResolutionStrategy(strategy: ArrayRightResolutionStrategy(strategy: ProtectedRightResolutionStrategy(rights: rights))))
    }

    public init<Rights : RightsManifest>(_ keyPath: KeyPath<ProtectedType, Value>,
                                         protectedBy rights: Rights) where Array<Optional<Rights.ProtectedType>> == Value, Strategy == ArrayRightResolutionStrategy<OptionalRightResolutionStrategy<ProtectedRightResolutionStrategy<Rights>>> {

        self.init(keyPath, strategy: ArrayRightResolutionStrategy(strategy: OptionalRightResolutionStrategy(strategy: ProtectedRightResolutionStrategy(rights: rights))))
    }

    public init<Rights : RightsManifest>(_ keyPath: KeyPath<ProtectedType, Value>,
                                         protectedBy rights: Rights) where Optional<Array<Optional<Rights.ProtectedType>>> == Value, Strategy == OptionalRightResolutionStrategy<ArrayRightResolutionStrategy<OptionalRightResolutionStrategy<ProtectedRightResolutionStrategy<Rights>>>> {

        self.init(keyPath, strategy: OptionalRightResolutionStrategy(strategy: ArrayRightResolutionStrategy(strategy: OptionalRightResolutionStrategy(strategy: ProtectedRightResolutionStrategy(rights: rights)))))
    }
}

extension ReadPropertyRight where Strategy == SimpleRightResolutionStrategy<Value> {
    public init(_ keyPath: KeyPath<ProtectedType, Value>) {
        self.init(keyPath, strategy: SimpleRightResolutionStrategy())
    }
}

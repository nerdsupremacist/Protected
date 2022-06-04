
import Foundation

public protocol RightsManifest {
    associatedtype ProtectedType
}

extension RightsManifest {
    public typealias Read<T, Strategy : RightResolutionStrategy> = ReadPropertyRight<ProtectedType, T, Strategy> where Strategy.Value == T
    public typealias Write<T> = WritePropertyRight<ProtectedType, T>
}


import Foundation

public protocol RightsManifest {
    associatedtype ProtectedType
}

extension RightsManifest {
    public typealias Resolved = Protected<ProtectedType, Self>
    public typealias Read<T> = ReadPropertyRight<ProtectedType, T>
    public typealias Write<T> = WritePropertyRight<ProtectedType, T>
}

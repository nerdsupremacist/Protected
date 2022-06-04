
import Foundation

public struct WritePropertyRight<ProtectedType, Value> {
    let keyPath: WritableKeyPath<ProtectedType, Value>

    public init(_ keyPath: WritableKeyPath<ProtectedType, Value>) {
        self.keyPath = keyPath
    }
}

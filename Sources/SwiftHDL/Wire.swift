import Foundation

public struct Width {
    let width: UInt

    public init(width: UInt) {
        self.width = width
    }

    public func get() -> UInt {
        self.width
    }
}

public struct HWUInt {
    let width: Width

    public init(width: Width) {
        self.width = width
    }
}

public struct Wire<T> {
    public let value: T
    public let name: String

    /// Initialize a Wire with a value and optional name
    public init(_ value: T, name: String = "") {
        self.value = value
        self.name = name
    }
}
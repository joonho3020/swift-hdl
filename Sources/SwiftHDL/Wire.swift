import Foundation

public struct Width {
    let width: Int

    public init(width: Int) {
        self.width = width
    }

    public func get() -> Int {
        self.width
    }
}

// Extension to add .W property to Int as well
extension Int {
    /// Creates a Width from an Int
    public var W: Width {
        return Width(width: Int(self))
    }
}

public struct HWUInt {
    let width: Width

    public init(_ width: Width) {
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
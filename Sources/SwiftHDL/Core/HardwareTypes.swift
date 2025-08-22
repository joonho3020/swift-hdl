import Foundation

// MARK: - Core Hardware Types
public extension Core {
    // MARK: - Width Type
    /// Represents the bit width of a hardware signal
    struct Width: ExpressibleByIntegerLiteral, Equatable {
        public let value: Int

        public init(integerLiteral value: Int) {
            self.value = value
        }

        public init(_ value: Int) {
            self.value = value
        }
    }

    // MARK: - Hardware UInt Type
    /// Hardware unsigned integer type with configurable width
    struct HardwareUInt: Equatable {
        public let width: Width
        public let value: UInt

        public init(_ value: UInt, width: Width) {
            self.value = value
            self.width = width
        }

        public init(_ value: UInt, width: Int) {
            self.value = value
            self.width = Width(width)
        }
    }

    // MARK: - Wire Type
    /// Represents a wire (combinational signal) in hardware
    class Wire<T> {
        public var value: T
        public let name: String

        public init(_ value: T, name: String = "") {
            self.value = value
            self.name = name
        }

        public func connect(_ newValue: T) {
            self.value = newValue
        }
    }

    // MARK: - Register Type
    /// Represents a register (sequential element) in hardware
    class Reg<T> {
        public var value: T
        public let name: String
        public var clock: Wire<Bool>?

        public init(_ initialValue: T, name: String = "") {
            self.value = initialValue
            self.name = name
            self.clock = nil
        }

        public func connect(_ newValue: T) {
            self.value = newValue
        }

        public func setClock(_ clock: Wire<Bool>) {
            self.clock = clock
        }

        public func tick() {
            // In a real implementation, this would be called on clock edge
            // For now, we'll just update the value
            // This is a simplified version
        }
    }
}

// MARK: - Extensions for convenience
extension Core.HardwareUInt {
    public static func + (lhs: Core.HardwareUInt, rhs: Core.HardwareUInt) -> Core.HardwareUInt {
        let maxWidth = max(lhs.width.value, rhs.width.value)
        let result = lhs.value + rhs.value
        return Core.HardwareUInt(result, width: Core.Width(maxWidth + 1))
    }

    public static func - (lhs: Core.HardwareUInt, rhs: Core.HardwareUInt) -> Core.HardwareUInt {
        let maxWidth = max(lhs.width.value, rhs.width.value)
        let result = lhs.value - rhs.value
        return Core.HardwareUInt(result, width: Core.Width(maxWidth))
    }

    public static func * (lhs: Core.HardwareUInt, rhs: Core.HardwareUInt) -> Core.HardwareUInt {
        let resultWidth = lhs.width.value + rhs.width.value
        let result = lhs.value * rhs.value
        return Core.HardwareUInt(result, width: Core.Width(resultWidth))
    }
}

// MARK: - Type aliases for common widths
public typealias UInt1 = Core.HardwareUInt
public typealias UInt8 = Core.HardwareUInt
public typealias UInt16 = Core.HardwareUInt
public typealias UInt32 = Core.HardwareUInt
public typealias UInt64 = Core.HardwareUInt

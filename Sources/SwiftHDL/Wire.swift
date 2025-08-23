import Foundation

public struct Width {
    public let width: Int
    public init(_ width: Int) { self.width = width }
}

public extension Int {
    var W: Width { Width(self) }
}

public protocol Signal {
    var bitWidth: Int { get }
}

public protocol NumericSignal: Signal {}

public struct HWUInt: NumericSignal {
  public let width: Width
  public init(_ width: Width) { self.width = width }
  public var bitWidth: Int { width.width }
}

public protocol Bundle: Signal {}

@dynamicMemberLookup
public struct Wire<T: Signal> {
  public let value: T
  public init(_ value: T) { self.value = value }

  // Generic, no-macro typed projection fallback for any Bundle
  public subscript<U: Signal>(dynamicMember kp: KeyPath<T, U>) -> Wire<U> where T: Bundle {
    let v = value[keyPath: kp]
    return Wire<U>(v)
  }
}

public func + (lhs: Wire<HWUInt>, rhs: Wire<HWUInt>) -> Wire<HWUInt> {
  let w = lhs.value.width
  return Wire(HWUInt(w))
}

// Re-export the macro attribute for end users
@attached(member, names: arbitrary)
public macro BundleDerive() = #externalMacro(module: "BundleDeriveMacros", type: "BundleDerive")
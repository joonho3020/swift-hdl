import Foundation

public struct Width: Equatable {
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

public struct NodeId: Hashable, Equatable {
    let id: Int
    public init(_ id: Int) { self.id = id }
}

public struct ModuleBuilder {
    private var _nextId = 0
    private var intern: [NodeId: Signal] = [:]

    public mutating func nextId() -> NodeId {
        let ret = NodeId(self._nextId)
        self._nextId += 1
        return ret
    }

    public init() {}
}

@dynamicMemberLookup
public struct Wire<T: Signal> {
  public let value: T
  var _id: Optional<NodeId> = nil

  public mutating func setId(_ id: NodeId) {
      self._id = id
  }

  public func getId() -> Optional<NodeId> {
      return self._id
  }

  public init(_ value: T) { self.value = value }
  init(_ value: T, _ id: NodeId) { self.value = value; self._id = id }

  public subscript<U: Signal>(dynamicMember kp: KeyPath<T, U>) -> Wire<U> where T: Bundle {
    assert(self._id != nil)
    let v = value[keyPath: kp]
    return Wire<U>(v, self._id!)
  }
}

public func + (lhs: Wire<HWUInt>, rhs: Wire<HWUInt>) -> Wire<HWUInt> {
  let w = lhs.value.width
  return Wire(HWUInt(w))
}

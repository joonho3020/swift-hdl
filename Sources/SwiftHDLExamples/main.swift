import SwiftHDL

let width1 = 8.W
let width2 = 16.W
let width3 = 32.W

print("Width 1: \(width1)")
print("Width 2: \(width2)")
print("Width 3: \(width3)")

let a = HWUInt(8.W)
let b = HWUInt(16.W)
print("HWUInt a: \(a)")
print("HWUInt b: \(b)")


// Re-export the macro attribute for end users
@attached(member, names: arbitrary)
public macro BundleDerive() = #externalMacro(module: "BundleDeriveMacros", type: "BundleDerive")

// Example nested bundles
@BundleDerive
public struct Header: Bundle {
  public var lo: HWUInt
  public var hi: HWUInt
}

@BundleDerive
public struct Packet: Bundle {
  public var hdr: Header
  public var payload: HWUInt
}

// // Generic bundle example
// @BundleDerive
// public struct Pair<A: Signal, B: Signal>: Bundle {
//   public var fst: A
//   public var snd: B
//   public init(_ fst: A, _ snd: B) { self.fst = fst; self.snd = snd }
// }

// Demo
let packet = Packet(hdr: Header(lo: HWUInt(8.W), hi: HWUInt(8.W)), payload: HWUInt(32.W))
let wp = Wire(packet)

// Typed accessors synthesized by the macro (plus the key-path fallback)
let lo: Wire<HWUInt> = wp.hdr.lo
let hi: Wire<HWUInt> = wp.hdr.hi
let sum = lo + hi

print("Packet bitWidth =", packet.bitWidth)  // via synthesized member: 8 + 8 + 32 = 48
print(packet)

// Generic bundle works too
// typealias U8 = HWUInt
// let pair = Pair(U8(8.W), U8(8.W))
// let wpair = Wire(pair, name: "pair")
// let fst: Wire<U8> = wpair.fst
// print("Pair fst width:", fst.value.bitWidth)

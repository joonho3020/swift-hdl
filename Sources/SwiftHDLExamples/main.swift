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
public macro BundleDerive() =
  #externalMacro(module: "BundleDeriveMacros", type: "BundleDerive")

// Example nested bundles
@BundleDerive
struct Header: Bundle {
  let lo = HWUInt(8.W)
  let hi = HWUInt(2.W)
}

@BundleDerive
struct Packet: Bundle {
  let hdr = Header()
  let pld = HWUInt(32.W)
}

// Demo
let packet = Packet()
var wp = Wire(packet)

var mb = ModuleBuilder()
let next_id = mb.nextId()
wp.setId(next_id)

// Typed accessors synthesized by the macro (plus the key-path fallback)
let lo: Wire<HWUInt> = wp.hdr.lo
let hi: Wire<HWUInt> = wp.hdr.hi
let sum = lo + hi

print("         packet:", packet)
print("Header field lo:", lo)
print("Header field hi:", hi)
print("            sum:", sum)

print(packet.bitWidth)

var x = HWUInt(8.W)
print(x.bitWidth)

var y = Header()
print(y.bitWidth)

assert(packet.bitWidth == 42)
assert(lo.getId() == NodeId(0))
assert(hi.getId() == NodeId(0))

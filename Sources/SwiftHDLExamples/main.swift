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
// @attached(member, names: arbitrary)
// public macro BundleDerive() =
// #externalMacro(module: "BundleDeriveMacros", type: "BundleDerive")

struct Header: Bundle {
    let lo = HWUInt(8.W)
    let hi = HWUInt(2.W)
}

struct Packet: Bundle {
    let hdr = Header()
    let pld = HWUInt(32.W)
}

class BPred: Bundle {
    let target: HWUInt
    let taken:  HWUInt

    public init(_ x: Int, _ y: Int) {
        self.target = HWUInt(x.W)
        self.taken  = HWUInt(y.W)
    }
}

var bpred = Wire(BPred(2, 3))

// Demo
let packet = Packet()
var wp = Wire(packet)

var mb = ModuleBuilder()
let next_id = mb.nextId()
wp.setId(next_id)

bpred.setId(mb.nextId())
let taken = bpred.taken

// Typed accessors synthesized by the macro (plus the key-path fallback)
let lo: Wire<HWUInt> = wp.hdr.lo
let hi: Wire<HWUInt> = wp.hdr.hi
let sum = lo + hi

print("         packet:", packet)
print("Header field lo:", lo)
print("Header field hi:", hi)
print("            sum:", sum)

let c = wp.hdr
let d = wp.pld
let e = wp.hdr.hi
let f = wp.hdr.lo

var x = HWUInt(8.W)
var y = Header()

// assert(packet.bitWidth == 42)
assert(c.getId() == NodeId(0))
assert(d.getId() == NodeId(0))
assert(e.getId() == NodeId(0))
assert(f.getId() == NodeId(0))
assert(lo.getId() == NodeId(0))
assert(hi.getId() == NodeId(0))

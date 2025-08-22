import SwiftHDL


print("=== SwiftHDL Basic Examples ===\n")

// Example 1: Simple counter
print("1. Counter Example:")
let clock = Core.Wire(false, name: "clock")
let counter = Core.Reg(Core.HardwareUInt(0, width: 4), name: "counter")
counter.setClock(clock)

for cycle in 0..<5 {
    print("  Cycle \(cycle): Counter = \(counter.value.value)")
    let newValue = counter.value + Core.HardwareUInt(1, width: 4)
    counter.connect(newValue)
    clock.connect(!clock.value)
}
print()

// Example 2: Simple adder
print("2. Adder Example:")
let a = Core.HardwareUInt(5, width: 8)
let b = Core.HardwareUInt(3, width: 8)
let result = a + b

print("  Adder: \(a.value) + \(b.value) = \(result.value)")
print("  Result width: \(result.width.value) bits")
print()

// Example 3: Wire connections
print("3. Wire Example:")
let inputWire = Core.Wire(Core.HardwareUInt(10, width: 4), name: "input")
let outputWire = Core.Wire(Core.HardwareUInt(0, width: 4), name: "output")

outputWire.connect(inputWire.value)

print("  Input wire: \(inputWire.value.value)")
print("  Output wire: \(outputWire.value.value)")
print()

// Example 4: Arithmetic operations
print("4. Arithmetic Operations:")
let x = Core.HardwareUInt(7, width: 4)
let y = Core.HardwareUInt(3, width: 4)

let sum = x + y
let diff = x - y
let product = x * y

print("  \(x.value) + \(y.value) = \(sum.value) (width: \(sum.width.value) bits)")
print("  \(x.value) - \(y.value) = \(diff.value) (width: \(diff.width.value) bits)")
print("  \(x.value) * \(y.value) = \(product.value) (width: \(product.width.value) bits)")

print("\n=== Examples Complete ===")

import SwiftHDL

func run() {
    // Test the new .W syntax
    let width1 = 8.W
    let width2 = 16.W
    let width3 = 32.W

    print("Width 1: \(width1.get())")
    print("Width 2: \(width2.get())")
    print("Width 3: \(width3.get())")

    // Create HWUInt using the new syntax
    let a = HWUInt(8.W)
    let b = HWUInt(16.W)
    print("HWUInt a: \(a)")
    print("HWUInt b: \(b)")
}

run()
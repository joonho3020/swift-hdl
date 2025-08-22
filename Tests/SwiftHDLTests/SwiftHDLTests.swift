import XCTest
@testable import SwiftHDL

final class SwiftHDLTests: XCTestCase {
    
    func testWidthInitialization() {
        let width1: Core.Width = 8
        let width2 = Core.Width(16)
        
        XCTAssertEqual(width1.value, 8)
        XCTAssertEqual(width2.value, 16)
    }
    
    func testHardwareUIntInitialization() {
        let signal1 = Core.HardwareUInt(42, width: 8)
        let signal2 = Core.HardwareUInt(255, width: Core.Width(8))
        
        XCTAssertEqual(signal1.value, 42)
        XCTAssertEqual(signal1.width.value, 8)
        XCTAssertEqual(signal2.value, 255)
        XCTAssertEqual(signal2.width.value, 8)
    }
    
    func testHardwareUIntArithmetic() {
        let a = Core.HardwareUInt(5, width: 4)
        let b = Core.HardwareUInt(3, width: 4)
        
        let sum = a + b
        let diff = a - b
        let product = a * b
        
        XCTAssertEqual(sum.value, 8)
        XCTAssertEqual(sum.width.value, 5) // 4 + 1 for carry
        XCTAssertEqual(diff.value, 2)
        XCTAssertEqual(diff.width.value, 4)
        XCTAssertEqual(product.value, 15)
        XCTAssertEqual(product.width.value, 8) // 4 + 4 for multiplication
    }
    
    func testWireOperations() {
        let wire = Core.Wire(Core.HardwareUInt(10, width: 4), name: "testWire")
        
        XCTAssertEqual(wire.value.value, 10)
        XCTAssertEqual(wire.name, "testWire")
        
        let newValue = Core.HardwareUInt(15, width: 4)
        wire.connect(newValue)
        XCTAssertEqual(wire.value.value, 15)
    }
    
    func testRegOperations() {
        let clock = Core.Wire(false, name: "clock")
        let reg = Core.Reg(Core.HardwareUInt(0, width: 4), name: "testReg")
        
        XCTAssertEqual(reg.value.value, 0)
        XCTAssertEqual(reg.name, "testReg")
        XCTAssertNil(reg.clock)
        
        reg.setClock(clock)
        XCTAssertNotNil(reg.clock)
        XCTAssertEqual(reg.clock?.value, false)
        
        let newValue = Core.HardwareUInt(7, width: 4)
        reg.connect(newValue)
        XCTAssertEqual(reg.value.value, 7)
    }
    
    func testTypeAliases() {
        // Test that type aliases work correctly
        let hwUInt8: HWUInt8 = Core.HardwareUInt(255, width: 8)
        let hwUInt16: HWUInt16 = Core.HardwareUInt(65535, width: 16)
        
        XCTAssertEqual(hwUInt8.value, 255)
        XCTAssertEqual(hwUInt8.width.value, 8)
        XCTAssertEqual(hwUInt16.value, 65535)
        XCTAssertEqual(hwUInt16.width.value, 16)
    }
    
    static var allTests = [
        ("testWidthInitialization", testWidthInitialization),
        ("testHardwareUIntInitialization", testHardwareUIntInitialization),
        ("testHardwareUIntArithmetic", testHardwareUIntArithmetic),
        ("testWireOperations", testWireOperations),
        ("testRegOperations", testRegOperations),
        ("testTypeAliases", testTypeAliases),
    ]
}

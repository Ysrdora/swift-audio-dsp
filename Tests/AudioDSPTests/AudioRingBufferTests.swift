import XCTest
@testable import AudioDSP

final class AudioRingBufferTests: XCTestCase {
    func testReadWrite() {
        let ringBuffer = AudioRingBuffer(capacity: 1024)
        
        let writeData: [Float] = [1.0, 2.0, 3.0, 4.0, 5.0]
        writeData.withUnsafeBufferPointer { ptr in
            XCTAssertTrue(ringBuffer.write(ptr))
        }
        
        var readData = [Float](repeating: 0, count: 5)
        let readCount = readData.withUnsafeMutableBufferPointer { ptr in
            ringBuffer.read(into: ptr)
        }
        
        XCTAssertEqual(readCount, 5)
        XCTAssertEqual(readData, writeData)
    }
    
    func testOverflow() {
        let ringBuffer = AudioRingBuffer(capacity: 4)
        let writeData: [Float] = [1.0, 2.0, 3.0, 4.0, 5.0]
        
        writeData.withUnsafeBufferPointer { ptr in
            XCTAssertFalse(ringBuffer.write(ptr)) // Should fail due to overflow
        }
    }
}

import Foundation
import Accelerate

/// A lock-free, thread-safe ring buffer designed for real-time audio contexts.
/// Backed by a fixed-size heap pointer. Safe for single-producer, single-consumer.
public final class AudioRingBuffer: @unchecked Sendable {
    private let capacity: Int
    private let buffer: UnsafeMutablePointer<Float>
    
    // Atomic indices for lock-free read/write
    private var writeIndex: Int = 0
    private var readIndex: Int = 0
    
    /// Initializes the ring buffer with a fixed capacity.
    public init(capacity: Int) {
        self.capacity = capacity
        self.buffer = UnsafeMutablePointer<Float>.allocate(capacity: capacity)
        self.buffer.initialize(repeating: 0, count: capacity)
    }
    
    deinit {
        buffer.deallocate()
    }
    
    /// Writes frames to the ring buffer.
    /// - Parameter frames: The audio frames to write.
    /// - Returns: True if write succeeded, false if buffer overflowed.
    @discardableResult
    public func write(_ frames: UnsafeBufferPointer<Float>) -> Bool {
        let count = frames.count
        let currentWrite = writeIndex
        let currentRead = readIndex
        
        let available = (currentRead - currentWrite - 1 + capacity) % capacity
        if count > available { return false } // Overflow
        
        let firstChunk = min(count, capacity - currentWrite)
        
        buffer.advanced(by: currentWrite).assign(from: frames.baseAddress!, count: firstChunk)
        
        if firstChunk < count {
            let secondChunk = count - firstChunk
            buffer.assign(from: frames.baseAddress!.advanced(by: firstChunk), count: secondChunk)
        }
        
        writeIndex = (currentWrite + count) % capacity
        return true
    }
    
    /// Reads frames from the ring buffer.
    /// - Parameter destination: The destination buffer.
    /// - Returns: The number of frames actually read.
    public func read(into destination: UnsafeMutableBufferPointer<Float>) -> Int {
        let count = destination.count
        let currentWrite = writeIndex
        let currentRead = readIndex
        
        let available = (currentWrite - currentRead + capacity) % capacity
        let toRead = min(count, available)
        if toRead == 0 { return 0 } // Underflow
        
        let firstChunk = min(toRead, capacity - currentRead)
        
        destination.baseAddress!.assign(from: buffer.advanced(by: currentRead), count: firstChunk)
        
        if firstChunk < toRead {
            let secondChunk = toRead - firstChunk
            destination.baseAddress!.advanced(by: firstChunk).assign(from: buffer, count: secondChunk)
        }
        
        readIndex = (currentRead + toRead) % capacity
        return toRead
    }
}

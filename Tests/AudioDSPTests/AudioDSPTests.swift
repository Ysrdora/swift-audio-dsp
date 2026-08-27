import XCTest
@testable import AudioDSP

final class SignalProcessorTests: XCTestCase {
    func testComputeFFT() {
        // Generate a 1024-sample sine wave at 440 Hz
        let sampleRate: Float = 44100.0
        let frequency: Float = 440.0
        let frameCount = 1024
        
        var frame = [Float](repeating: 0, count: frameCount)
        for i in 0..<frameCount {
            let t = Float(i) / sampleRate
            frame[i] = sin(2.0 * .pi * frequency * t)
        }
        
        let magnitudes = SignalProcessor.computeFFT(frame: frame)
        XCTAssertEqual(magnitudes.count, frameCount / 2)
        
        // Find peak frequency bin
        guard let maxMag = magnitudes.max(), let maxIndex = magnitudes.firstIndex(of: maxMag) else {
            XCTFail("Could not compute FFT magnitudes")
            return
        }
        
        let binFrequency = Float(maxIndex) * sampleRate / Float(frameCount)
        XCTAssertEqual(binFrequency, frequency, accuracy: 50.0)
    }
}

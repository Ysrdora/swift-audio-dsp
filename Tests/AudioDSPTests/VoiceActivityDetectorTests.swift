import XCTest
@testable import AudioDSP

final class VoiceActivityDetectorTests: XCTestCase {
    func testVoiceDetection() {
        let vad = VoiceActivityDetector(energyThreshold: 0.1)
        
        // Generate loud signal
        var loudFrame = [Float](repeating: 0, count: 1024)
        for i in 0..<1024 {
            loudFrame[i] = sin(Float(i)) * 0.8
        }
        XCTAssertTrue(vad.isVoicePresent(in: loudFrame))
        
        // Generate silence
        let silentFrame = [Float](repeating: 0, count: 1024)
        XCTAssertFalse(vad.isVoicePresent(in: silentFrame))
    }
}

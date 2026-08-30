import Foundation
import Accelerate

/// A lightweight, energy-efficient voice activity detector (VAD).
/// Uses spectral energy thresholding on FFT magnitudes.
public struct VoiceActivityDetector: Sendable {
    private let energyThreshold: Float
    
    public init(energyThreshold: Float = 0.05) {
        self.energyThreshold = energyThreshold
    }
    
    /// Detects if speech is present in the given audio frame.
    /// - Parameter frame: The raw audio samples.
    /// - Returns: True if voice activity is detected.
    public func isVoicePresent(in frame: [Float]) -> Bool {
        let magnitudes = SignalProcessor.computeFFT(frame: frame)
        guard !magnitudes.isEmpty else { return false }
        
        // Compute average energy in the speech band (roughly 300Hz - 3000Hz)
        // For simplicity in this implementation, we average all bins.
        var sum: Float = 0
        vDSP_sve(magnitudes, 1, &sum, vDSP_Length(magnitudes.count))
        
        let averageEnergy = sum / Float(magnitudes.count)
        return averageEnergy > energyThreshold
    }
}

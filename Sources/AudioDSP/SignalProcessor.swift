import Foundation
import Accelerate

/// A high-performance audio signal processor backed by the Accelerate framework.
/// Designed for strict Swift 6 concurrency and real-time audio threads.
public struct SignalProcessor: Sendable {
    
    /// Applies a fast Fourier transform (FFT) to the given audio frame.
    /// - Parameter frame: The input audio samples (must be a power of 2 in length).
    /// - Returns: The frequency magnitudes.
    public static func computeFFT(frame: [Float]) -> [Float] {
        let n = vDSP_Length(frame.count)
        guard n > 0, (n & (n - 1)) == 0 else {
            return [] // Must be power of 2
        }
        
        let log2n = vDSP_Length(log2(Float(n)))
        guard let setup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2)) else {
            return []
        }
        defer { vDSP_destroy_fftsetup(setup) }
        
        var real = [Float](repeating: 0, count: Int(n / 2))
        var imag = [Float](repeating: 0, count: Int(n / 2))
        
        var magnitudes = [Float](repeating: 0, count: Int(n / 2))
        
        real.withUnsafeMutableBufferPointer { realPtr in
            imag.withUnsafeMutableBufferPointer { imagPtr in
                var splitComplex = DSPSplitComplex(realp: realPtr.baseAddress!, imagp: imagPtr.baseAddress!)
                
                frame.withUnsafeBufferPointer { framePtr in
                    framePtr.baseAddress!.withMemoryRebound(to: DSPComplex.self, capacity: Int(n / 2)) { complexPtr in
                        vDSP_ctoz(complexPtr, 2, &splitComplex, 1, n / 2)
                    }
                }
                
                vDSP_fft_zrip(setup, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))
                
                // Scale according to Accelerate documentation
                var scale: Float = 0.5
                vDSP_vsmul(splitComplex.realp, 1, &scale, splitComplex.realp, 1, n / 2)
                vDSP_vsmul(splitComplex.imagp, 1, &scale, splitComplex.imagp, 1, n / 2)
                
                vDSP_zvabs(&splitComplex, 1, &magnitudes, 1, n / 2)
            }
        }
        
        return magnitudes
    }
}

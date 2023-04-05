import AVFoundation

class WaveformExtractor {
    
    private var audioFile: AVAudioFile?
    private var audioFileLengthInFrames: AVAudioFramePosition = 0
    private var audioFileSampleRate: Int = 0
    private var sampleStep: Int = 0
    
    func open(inputFilename: String) throws {
        let url = URL(fileURLWithPath: inputFilename)
        audioFile = try AVAudioFile(forReading: url)
        audioFileLengthInFrames = audioFile!.length
        audioFileSampleRate = Int(audioFile!.processingFormat.sampleRate)

        let duration = Int(round(Double(getDuration()) / 1000000.0))
        sampleStep = max(duration / 10, 1)
    }
    
    func release() {
        audioFile = nil
        audioFileLengthInFrames = 0
        audioFileSampleRate = 0
    }
    
    // Read the raw audio data in 16-bit format
    // This function should return a small chunk of the entire data
    // and called repeatedly until EOF
    // Returns nil on EOF
    func readShortData(chunkSize: AVAudioFrameCount) -> [Int8]? {
        guard let audioFile = audioFile else {
            return nil
        }
        guard let audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: chunkSize) else {
            return nil
        }
        do {
            try audioFile.read(into: audioFileBuffer)
        } catch {
            return nil
        }
        guard let audioData = audioFileBuffer.int16ChannelData?[0] else {
            return nil
        }
        let audioDataCount = Int(audioFileBuffer.frameLength) * audioFileBuffer.format.channelCount
        let audioDataBuffer = UnsafeBufferPointer(start: audioData, count: audioDataCount)
        let samples = [Int16](audioDataBuffer)

        return simplifyData(samples);
    }

    func simplifyData(samples: [Int16]) -> [Int8] {
        var cursor = 0
        var simplifiedSamples = [Int8]()
        simplifiedSamples.reserveCapacity(samples.count / (4 * sampleStep))

        for i in 0..<samples.count {
            if cursor % (sampleStep * 4) == 1 {
                var val = Int(abs(samples[i]))

                // do a rudimentary dynamic range expansion
                if val < 30 {
                    val = Int(Double(val) * 0.2)
                }
                if val > 40 {
                    val = Int(Double(val) * 1.5)
                }

                if simplifiedSamples.count < samples.count / (4 * sampleStep) {
                    simplifiedSamples.append(Int8(truncatingIfNeeded: val))
                }
            }
            cursor += 1
        }

        return simplifiedSamples
    }
    
    // Return the Audio sample rate, in samples/sec.
    func getSampleRate() -> Int {
        return audioFileSampleRate
    }
    
    // Return the duration of the audio file in seconds.
    func getDuration() -> Int64 {
        let duration = Double(audioFileLengthInFrames) / audioFileSampleRate
        return Int64(duration * 1_000_000)
    }
}
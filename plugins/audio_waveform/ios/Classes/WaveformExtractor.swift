import AVFoundation
import MediaPlayer

class WaveformExtractor {
    
    private var audioFile: AVAudioFile?
    private var audioFileLengthInFrames: AVAudioFramePosition = 0
    private var audioFileSampleRate: Int = 0
    private var sampleStep: Int = 0
    
    func getFileURL(from mediaLibraryItemID: String) -> URL? {
        let query = MPMediaQuery.songs()
        let predicate = MPMediaPropertyPredicate(value: mediaLibraryItemID, forProperty: MPMediaItemPropertyPersistentID)
        query.addFilterPredicate(predicate)
        guard let mediaItem = query.items?.first else {
            return nil
        }
        return mediaItem.assetURL
    }

    func open(inputFilename: String) throws {
        if let url = getFileURL(from: inputFilename) {
            print(url.description)
            audioFile = try AVAudioFile(forReading: url)
            audioFileLengthInFrames = audioFile!.length
            audioFileSampleRate = Int(audioFile!.processingFormat.sampleRate)

            let duration = Int(round(Double(getDuration()) / 1000000.0))
            sampleStep = max(duration / 10, 1)
        } else {
            print("Error: could not create URL from inputFilename")
            return
        }
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
    func readShortData(chunkSize: AVAudioFrameCount) -> [UInt8]? {
        guard let audioFile = audioFile else {
            return nil
        }
        guard let format = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 44100, channels: 2, interleaved: false) else {
            return nil
        }

        guard let audioFileBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: chunkSize) else {
            return nil
        }
        do {
            try audioFile.read(into: audioFileBuffer)
        } catch {
            return nil
        }
        print("Buffer len \(audioFileBuffer.frameLength)")
        guard let audioData = audioFileBuffer.int16ChannelData?[0] else {
            return nil
        }
        let audioDataCount = Int(audioFileBuffer.frameLength) * Int(audioFileBuffer.format.channelCount)
        let audioDataBuffer = UnsafeBufferPointer(start: audioData, count: audioDataCount)
        let samples = [Int16](audioDataBuffer)

        return simplifyData(samples: samples);
    }

    func simplifyData(samples: [Int16]) -> [UInt8] {
        let finalSize = samples.count / (4 * sampleStep)
        var simplifiedSamples = [UInt8](repeating: 0, count: finalSize)

        for i in 0..<samples.count {
            if i % (sampleStep * 4) == 1 {
                var val = Int(abs(samples[i]))

                // do a rudimentary dynamic range expansion
                if val < 30 {
                    val = Int(Double(val) * 0.2)
                }
                if val > 40 {
                    val = Int(Double(val) * 1.5)
                }

                if simplifiedSamples.count < finalSize {
                    simplifiedSamples[i / (sampleStep * 4)] = UInt8(truncatingIfNeeded: val)
                }
            }
        }

        return simplifiedSamples
    }
    
    // Return the Audio sample rate, in samples/sec.
    func getSampleRate() -> Int {
        return audioFileSampleRate
    }
    
    // Return the duration of the audio file in seconds.
    func getDuration() -> Int64 {
        let duration = Double(audioFileLengthInFrames) / Double(audioFileSampleRate)
        return Int64(duration * 1_000_000)
    }
}

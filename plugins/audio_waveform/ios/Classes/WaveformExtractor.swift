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
            return URL(string: mediaLibraryItemID)
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

        guard let audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: chunkSize) else {
            return nil
        }
        do {
            try audioFile.read(into: audioFileBuffer)
        } catch {
            return nil
        }
        
        guard let audioData = audioFileBuffer.floatChannelData?[0] else {
            return nil
        }
        let audioDataCount = Int(audioFileBuffer.frameLength) * Int(audioFileBuffer.format.channelCount)
        let audioDataBuffer = UnsafeBufferPointer(start: audioData, count: audioDataCount)
        let samples = [Float](audioDataBuffer)

        return simplifyData(samples: samples);
    }

    func simplifyData(samples: [Float]) -> [UInt8] {
        let finalSize = samples.count / (2 * sampleStep) + 1
        var simplifiedSamples = [UInt8](repeating: 0, count: finalSize)

        for i in stride(from: 0, to: samples.count/2, by: sampleStep) {
            var val = UInt16(abs(samples[i])*256)

            // do a rudimentary dynamic range expansion
           if val < 30 {
               val = val / 5
           }
           else if val > 40 {
               val = (val * 15) / 10
               if val>255 {
                   val=255
               }
           }

            //if i / (sampleStep * 2) < simplifiedSamples.count {
                simplifiedSamples[i / (sampleStep)] = UInt8(truncatingIfNeeded: val)
            //}
        }

        return simplifiedSamples
    }
    
    // Return the Audio sample rate, in samples/sec.
    func getSampleRate() -> Int {
        return audioFileSampleRate
    }
    
    // Return the duration of the audio file in microseconds.
    func getDuration() -> Int64 {
        let duration = Double(audioFileLengthInFrames) / Double(audioFileSampleRate)
        return Int64(duration * 1_000_000)
    }
}

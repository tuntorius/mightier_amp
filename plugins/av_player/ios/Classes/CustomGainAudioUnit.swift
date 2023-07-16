import AVFoundation
/*
class CustomGainEffect: AVAudioUnitEffect {
    private var gain: Float = 0.0
    
    override init(audioComponentDescription: AudioComponentDescription) {
        super.init(audioComponentDescription: audioComponentDescription)
        
        // Set the default gain value
        gain = 0.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Set the gain in decibels
    func setGainInDecibels(_ gainInDecibels: Float) {
        gain = pow(10.0, gainInDecibels / 20.0)
    }
    
    // Custom processing function
    override func internalRenderBlock(bufferList: UnsafeMutablePointer<AudioBufferList>,
                                      frameCount: UInt32,
                                      timeStamp: UnsafePointer<AudioTimeStamp>) -> OSStatus {
        guard let buffer = bufferList.pointee.mBuffers.mData?.assumingMemoryBound(to: Float.self) else {
            return noErr
        }
        
        let sampleCount = Int(frameCount)
        
        // Apply the gain to each audio sample
        for i in 0..<sampleCount {
            buffer[i] *= gain
        }
        
        return noErr
    }
}*/
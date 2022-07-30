#import "AudioWaveformPlugin.h"

@implementation AudioWaveformPlugin {
    FlutterMethodChannel *_channel;
    ExtAudioFileRef audioFileRef = NULL;
    int mSampleRate;
    int mDuration;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [[AudioWaveformPlugin alloc] initWithRegistrar:registrar];
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    self = [super init];
    NSAssert(self, @"super init cannot be nil");
    _channel = [FlutterMethodChannel
        methodChannelWithName:@"com.tuntori.audio_waveform"
              binaryMessenger:[registrar messenger]];
    [registrar addMethodCallDelegate:self channel:_channel];
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    NSDictionary *request = (NSDictionary *)call.arguments;

    if ([@"open" isEqualToString:call.method]) {
        NSString *audioInPath = (NSString *)request[@"path"];
        //open and prepare the audio here
        //store duration and sample rate
        OSStatus status;
        UInt32 size;
        CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)audioInPath, kCFURLPOSIXPathStyle, false);
        status = ExtAudioFileOpenURL(url, &audioFileRef);
        if (status != noErr) {
            NSLog(@"ExtAudioOpenURL error: %i", status);
            dispatch_async(dispatch_get_main_queue(), ^{
                result([FlutterError errorWithCode:@"ExtAudioOpenURL error" message:@"ExtAudioOpenURL error" details:nil]);
            });
            return;
        }

        AudioStreamBasicDescription fileFormat;
        size = sizeof(fileFormat);
        status = ExtAudioFileGetProperty(audioFileRef, kExtAudioFileProperty_FileDataFormat, &size, &fileFormat);
        if (status != noErr) {
            NSLog(@"ExtAudioFileGetProperty error: %i", status);
            dispatch_async(dispatch_get_main_queue(), ^{
                result([FlutterError errorWithCode:@"Error reading file format" message:@"Error reading file format" details:nil]);
            });
            return;
        }

        SInt64 expectedSampleCount = 0;
        size = sizeof(expectedSampleCount);
        status = ExtAudioFileGetProperty(audioFileRef, kExtAudioFileProperty_FileLengthFrames, &size, &expectedSampleCount);
        if (status != noErr) {
            NSLog(@"ExtAudioFileGetProperty error: %i", status);
            dispatch_async(dispatch_get_main_queue(), ^{
                result([FlutterError errorWithCode:@"Error reading sample count" message:@"Error reading sample count" details:nil]);
            });
            return;
        }

        mSampleRate = (int)fileFormat.mSampleRate;
        mDuration = (int)(expectedSampleCount / fileFormat.mSampleRate);

    }
    else if ([@"next" isEqualToString:call.method]) {
        //just get the next buffer here

    }
    else if ([@"close" isEqualToString:call.method]) {
        
    }
    else if ([@"duration" isEqualToString:call.method]) {
        result();
    }
    else if ([@"sampleRate" isEqualToString:call.method]) {
        result(mSampleRate);
    }

    if ([@"extract" isEqualToString:call.method]) {
        NSString *audioInPath = (NSString *)request[@"audioInPath"];
        NSString *waveOutPath = (NSString *)request[@"waveOutPath"];
        NSNumber *samplesPerPixelArg = (NSNumber *)request[@"samplesPerPixel"];
        NSNumber *pixelsPerSecondArg = (NSNumber *)request[@"pixelsPerSecond"];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            /*
            OSStatus status;
            UInt32 size;
            CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)audioInPath, kCFURLPOSIXPathStyle, false);
            status = ExtAudioFileOpenURL(url, &audioFileRef);
            if (status != noErr) {
                NSLog(@"ExtAudioOpenURL error: %i", status);
                dispatch_async(dispatch_get_main_queue(), ^{
                    result([FlutterError errorWithCode:@"ExtAudioOpenURL error" message:@"ExtAudioOpenURL error" details:nil]);
                });
                return;
            }
            AudioStreamBasicDescription fileFormat;
            size = sizeof(fileFormat);
            status = ExtAudioFileGetProperty(audioFileRef, kExtAudioFileProperty_FileDataFormat, &size, &fileFormat);
            if (status != noErr) {
                NSLog(@"ExtAudioFileGetProperty error: %i", status);
                dispatch_async(dispatch_get_main_queue(), ^{
                    result([FlutterError errorWithCode:@"Error reading file format" message:@"Error reading file format" details:nil]);
                });
                return;
            }

            
            SInt64 expectedSampleCount = 0;
            size = sizeof(expectedSampleCount);
            status = ExtAudioFileGetProperty(audioFileRef, kExtAudioFileProperty_FileLengthFrames, &size, &expectedSampleCount);
            if (status != noErr) {
                NSLog(@"ExtAudioFileGetProperty error: %i", status);
                dispatch_async(dispatch_get_main_queue(), ^{
                    result([FlutterError errorWithCode:@"Error reading sample count" message:@"Error reading sample count" details:nil]);
                });
                return;
            }
            */
            //NSLog(@"channel count = %d", fileFormat.mChannelsPerFrame);
            //NSLog(@"Sample rate = %f", fileFormat.mSampleRate);
            //NSLog(@"expected sample count = %d", expectedSampleCount);

            //NSLog(@"frames per packet: %d", fileFormat.mFramesPerPacket);

            int samplesPerPixel;
            if (samplesPerPixelArg != (id)[NSNull null]) {
                samplesPerPixel = [samplesPerPixelArg intValue];
            } else {
                samplesPerPixel = (int)(fileFormat.mSampleRate / [pixelsPerSecondArg intValue]);
            }

            // Multiply by 2 since 2 bytes are needed for each short, and multiply by 2 again because for each sample we store a pair of (min,max)
            UInt32 scaledByteSamplesLength = 2*2*(UInt32)(expectedSampleCount / samplesPerPixel);
            UInt32 waveLength = (UInt32)(scaledByteSamplesLength / 2); // better name: numPixels?
            //NSLog(@"wave length = %d", waveLength);

            int bytesPerChannel = 2;
            AudioStreamBasicDescription clientFormat;
            clientFormat.mSampleRate = fileFormat.mSampleRate;
            clientFormat.mFormatID = kAudioFormatLinearPCM;
            clientFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger;
            clientFormat.mBitsPerChannel = bytesPerChannel * 8;
            clientFormat.mChannelsPerFrame = fileFormat.mChannelsPerFrame;
            clientFormat.mBytesPerFrame = clientFormat.mChannelsPerFrame * bytesPerChannel;
            clientFormat.mFramesPerPacket = 1;
            clientFormat.mBytesPerPacket = clientFormat.mFramesPerPacket * clientFormat.mBytesPerFrame;

            status = ExtAudioFileSetProperty(audioFileRef, kExtAudioFileProperty_ClientDataFormat, sizeof(AudioStreamBasicDescription), &clientFormat);
            if (status != noErr) {
                NSLog(@"ExtAudioFileSetProperty error: %i", status);
                dispatch_async(dispatch_get_main_queue(), ^{
                    result([FlutterError errorWithCode:@"Error setting client format" message:@"Error setting client format" details:nil]);
                });
                return;
            }

            UInt32 packetsPerBuffer = 4096; // samples/frames per buffer
            UInt32 outputBufferSize = packetsPerBuffer * clientFormat.mBytesPerPacket;

            AudioBufferList convertedData;
            convertedData.mNumberBuffers = 1;
            convertedData.mBuffers[0].mNumberChannels = clientFormat.mChannelsPerFrame;
            convertedData.mBuffers[0].mDataByteSize = outputBufferSize;
            // XXX: Do we need to free this on iOS?
            convertedData.mBuffers[0].mData = (UInt8 *)malloc(sizeof(UInt8 *) * outputBufferSize);

            UInt32 frameCount = packetsPerBuffer;
            UInt32 sampleIdx = 0;
            short minSample = 32767;
            short maxSample = -32768;
            int waveHeaderLength = 20;
            UInt32 waveFileContentLength = waveHeaderLength + sizeof(short *) * waveLength;
            UInt8 *waveFileContent = (UInt8 *)malloc(waveFileContentLength);
            UInt32 *waveHeader = (UInt32 *)waveFileContent;
            short *wave = (short *)(waveFileContent + waveHeaderLength);
            UInt32 scaledSampleIdx = 0;
            int progress = 0;

            while (frameCount > 0) {
                status = ExtAudioFileRead(audioFileRef, &frameCount, &convertedData);
                if (status != noErr) {
                    NSLog(@"ExtAudioFileRead error: %i", status);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        result([FlutterError errorWithCode:@"ExtAudioFileRead error" message:@"ExtAudioFileRead error" details:nil]);
                    });
                    break;
                }
                if (frameCount > 0) {
                    AudioBuffer audioBuffer = convertedData.mBuffers[0];
                    short *samples = (short *)audioBuffer.mData;

                    // Each frame may have two channels making 2*frameCount individual L/R samples.
                    int sampleCount = clientFormat.mChannelsPerFrame * frameCount;
                    for (int i = 0; i < sampleCount; i += clientFormat.mChannelsPerFrame) {
                        long sample = 0;
                        for (int j = 0; j < clientFormat.mChannelsPerFrame; j++) {
                            sample += samples[i+j];
                        }
                        sample /= clientFormat.mChannelsPerFrame;
                        if (sample < -32768) sample = -32768;
                        if (sample > 32767) sample = 32767;
                        if (sample < minSample) minSample = (short)sample;
                        if (sample > maxSample) maxSample = (short)sample;
                        sampleIdx++;
                        if (sampleIdx % samplesPerPixel == 0) {
                            if (scaledSampleIdx + 1 < waveLength) {
                                wave[scaledSampleIdx++] = minSample;
                                wave[scaledSampleIdx++] = maxSample;
                                int newProgress = (int)(100 * scaledSampleIdx / waveLength);
                                if (newProgress != progress && newProgress <= 100) {
                                    progress = newProgress;

                                    //TODO: send buffer data here, but it looks like it's not a buffer at all, but
                                    //each single value separately
                                    //NSLog(@"Progress: %d percent", progress);
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [_channel invokeMethod:@"onProgress" arguments:@(progress)];
                                    });
                                }
                                //NSLog(@"pixel[%d] %d: %d\t%d", scaledSampleIdx - 2, sampleIdx, minSample, maxSample);
                                minSample = 32767;
                                maxSample = -32768;
                            }
                        }
                    }
                }
            }

            // Set header, compatible with audiowaveform format.
            waveHeader[0] = 1; // version
            waveHeader[1] = 0; // flags - 16 bit
            waveHeader[2] = (UInt32)fileFormat.mSampleRate;
            waveHeader[3] = samplesPerPixel;
            waveHeader[4] = (UInt32)(scaledSampleIdx / 2);
            //for (int i = 0; i < 5; i++) {
            //    NSLog(@"waveHeader[%d] = %d", i, waveHeader[i]);
            //}
            NSData *waveData = [NSData dataWithBytesNoCopy:(void *)waveFileContent length:(waveHeaderLength + 2*scaledSampleIdx)];
            [waveData writeToFile:waveOutPath atomically:NO];
            //NSLog(@"Total scaled samples: %d", scaledSampleIdx);

            status = ExtAudioFileDispose(audioFileRef);

            dispatch_async(dispatch_get_main_queue(), ^{
                result(nil);
            });
        });
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end

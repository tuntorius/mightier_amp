
package com.tuntori.audio_waveform;

//https://imnotyourson.com/enhance-poor-performance-of-decoding-audio-with-mediaextractor-and-mediacodec-to-pcm/

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.ShortBuffer;
import java.util.Arrays;
import java.util.LinkedList;
import android.content.Context;
import 	android.content.res.AssetFileDescriptor;
import android.media.MediaCodec;
import android.media.MediaExtractor;
import android.media.MediaFormat;
import android.net.Uri;
import android.util.Log;

public class SimpleEncoder {
    private Boolean VERBOSE = false;
    private String TAG = "SimpleEncoder";
    private int DECODE_INPUT_SIZE = 524288; // 524288 Bytes = 0.5 MB
    private int BUFFER_OVERFLOW_SAFE_GATE = 5000;
    // Analog audio is recorded by sampling it 44,100 times per second, and then these samples are used to reconstruct the audio signal when playing it back.
    // ref:https://en.wikipedia.org/wiki/44,100_Hz#Related_rates
    public static final int DEFAULT_SAMPLE_RATE = 44100;
    private ProgressListener mProgressListener = null;

    // Member variables representing frame data
    private int mFileSize;
    private int mSampleRate;
    private int mChannels;
    private long mDuration;
    private int mNumSamples;  // total number of samples per channel in audio file
    private ByteBuffer mDecodedBytes;  // Raw audio data
    private byte[] mDecodedData;  // shared buffer with mDecodedBytes.
    // mDecodedSamples has the following format:
    // {s1c1, s1c2, ..., s1cM, s2c1, ..., s2cM, ..., sNc1, ..., sNcM}
    // where sicj is the ith sample of the jth channel (a sample is a signed short)
    // M is the number of channels (e.g. 2 for stereo) and N is the number of samples per channel.

    private MediaCodec mAudioDecoder = null;
    private MediaFormat mDecoderOutputAudioFormat = null;
    private boolean mAudioExtractorDone = false;
    private boolean mAudioInputBufferEOF = false;
    private boolean mAudioDecoderDone = false;
    private MediaExtractor mAudioExtractor = null;
    private int mAudioExtractedFrameCount = 0;
    private int mAudioDecodedFrameCount = 0;
    private int mAudioExtractedTotalSize = 0;
    private int decodedSamplesSize = 0;  // size of the output buffer containing decoded samples.
    private byte[] decodedSamples = null;
    private int sampleStep = 1;

    private LinkedList<Integer> mPendingAudioDecoderOutputBufferIndices;
    private LinkedList<MediaCodec.BufferInfo> mPendingAudioDecoderOutputBufferInfos;

    // Progress listener interface.
    public interface ProgressListener {
        //
         // Will be called by the SoundFile class periodically
         // with values between 0.0 and 1.0.  Return true to continue
         // loading the file or recording the audio, and false to cancel or stop recording.
         ///
        boolean reportProgress(double fractionComplete);
    }

    // Custom exception for invalid inputs.
    public class InvalidInputException extends Exception {
        public InvalidInputException(String message) {
            super(message);
        }
    }

    // Create and return a SimpleEncoder object using the file fileName.
    public static SimpleEncoder create(String fileName, Context context, 
                                       ProgressListener progressListener)
            throws FileNotFoundException,
            java.io.IOException, InvalidInputException {

        SimpleEncoder simpleEncoder = new SimpleEncoder();
        simpleEncoder.setProgressListener(progressListener);
        simpleEncoder.ReadFile(fileName, context);
        return simpleEncoder;
    }

    public int getFileSizeBytes() {
        return mFileSize;
    }

    public int getSampleRate() {
        return mSampleRate;
    }

    public int getChannels() {
        return mChannels;
    }

    public long getDuration() {
        return mDuration;
    }

    public int getNumSamples() {
        return mNumSamples;  // Number of samples per channel.
    }

    public byte[] getSamples() {
        return mDecodedData;
    }

    private SimpleEncoder() {
    }

    private void setProgressListener(ProgressListener progressListener) {
        mProgressListener = progressListener;
    }

    private void logState() {
        if (VERBOSE) {
            Log.d(TAG, String.format(
                    "loop: "
                            + "{"
                            + "extracted:%d(done:%b) "
                            + "decoded:%d(done:%b) ",

                    mAudioExtractedFrameCount, mAudioExtractorDone,
                    mAudioDecodedFrameCount, mAudioDecoderDone
            ));
        }
    }

    private void decodeAudio() {
        if (mPendingAudioDecoderOutputBufferIndices.size() == 0) {
            return;
        }
        int decoderIndex = mPendingAudioDecoderOutputBufferIndices.poll();
        MediaCodec.BufferInfo info = mPendingAudioDecoderOutputBufferInfos.poll();

        int size = info.size;
        long presentationTime = info.presentationTimeUs;
        if (VERBOSE) {
            Log.d(TAG, "audio decoder: processing pending buffer: "
                    + decoderIndex);
            Log.d(TAG, "audio decoder: pending buffer of size " + size);
            Log.d(TAG, "audio decoder: pending buffer for time " + presentationTime);
        }
        if (size >= 0) {
            ByteBuffer decoderOutputBuffer = mAudioDecoder.getOutputBuffer(decoderIndex).duplicate();
            if (decodedSamplesSize < info.size) {
                decodedSamplesSize = info.size;
                decodedSamples = new byte[decodedSamplesSize];
            }
            decoderOutputBuffer.get(decodedSamples, 0, info.size);
            mAudioDecoder.releaseOutputBuffer(decoderIndex, false);
            // Check if buffer is big enough. Resize it if it's too small.
            if (mDecodedBytes.remaining() < info.size) {
                // Getting a rough estimate of the total size, allocate 20% more, and
                // make sure to allocate at least 5MB more than the initial size.
                int position = mDecodedBytes.position();
                int newSize = (int) ((position * (1.0 * mFileSize / mAudioExtractedTotalSize)) * 1.2);
                if (newSize - position < info.size + 5 * (1 << 20)) {
                    newSize = position + info.size + 5 * (1 << 20);
                }
                ByteBuffer newDecodedBytes = null;
                // Try to allocate memory. If we are OOM, try to run the garbage collector.
                int retry = 10;
                while (retry > 0) {
                    try {
                        newDecodedBytes = ByteBuffer.allocate(newSize);
                        break;
                    } catch (OutOfMemoryError oome) {
                        // setting android:largeHeap="true" in <application> seem to help not
                        // reaching this section.
                        retry--;
                    }
                }
                if (retry == 0) {
                    // Failed to allocate memory... Stop reading more data and finalize the
                    // instance with the data decoded so far.
                    Log.e(TAG, "Failed to allocate memory... Stop reading more data");
                }
                //ByteBuffer newDecodedBytes = ByteBuffer.allocate(newSize);
                mDecodedBytes.rewind();
                newDecodedBytes.put(mDecodedBytes);
                mDecodedBytes = newDecodedBytes;
                mDecodedBytes.position(position);
            }
            mDecodedBytes.put(decodedSamples, 0, info.size);
        }
        if ((info.flags
                & MediaCodec.BUFFER_FLAG_END_OF_STREAM) != 0) {
            Log.d(TAG, "audio decoder: EOS");
            synchronized (this) {
                mAudioDecoderDone = true;
                notifyAll();
            }
        }
        logState();
    }

    // 
    //   Creates a decoder for the given format.
    //  
    //   @param inputFormat the format of the stream to decode
    //  
    private MediaCodec createAudioDecoder(MediaFormat inputFormat) throws IOException {
        inputFormat.setInteger(MediaFormat.KEY_MAX_INPUT_SIZE, DECODE_INPUT_SIZE); // huge throughput
        MediaCodec decoder = MediaCodec.createDecoderByType(inputFormat.getString(MediaFormat.KEY_MIME));
        decoder.setCallback(new MediaCodec.Callback() {
            public void onError(MediaCodec codec, MediaCodec.CodecException exception) {
                Log.e(TAG, exception.toString());
            }
            public void onOutputFormatChanged(MediaCodec codec, MediaFormat format) {
                mDecoderOutputAudioFormat = codec.getOutputFormat();
                if (VERBOSE) {
                    Log.d(TAG, "audio decoder: output format changed: "
                            + mDecoderOutputAudioFormat);
                }
            }
            public void onInputBufferAvailable(MediaCodec codec, int index) {
                ByteBuffer decoderInputBuffer = codec.getInputBuffer(index);
                while (!mAudioExtractorDone && !mAudioInputBufferEOF) {
                    int bufferChunkSize = 0;
                    long presentationTime = 0;
                    while (true) {
                        ByteBuffer tempBuffer = ByteBuffer.allocate(1 << 10);
                        int size = mAudioExtractor.readSampleData(tempBuffer, 0);
                        if (size > 0) {
                            bufferChunkSize += size;
                            decoderInputBuffer.put(tempBuffer);
                            mAudioExtractedTotalSize += size;
                            presentationTime += mAudioExtractor.getSampleTime();
                            if (VERBOSE) {
                                Log.d(TAG, "audio extractor: returned buffer of size " + size);
                                Log.d(TAG, "audio extractor: returned buffer for time " + presentationTime);
                            }
                        }
                        mAudioExtractorDone = !mAudioExtractor.advance() && size == -1;
                        mAudioExtractedFrameCount++;
                        if (bufferChunkSize > (DECODE_INPUT_SIZE - BUFFER_OVERFLOW_SAFE_GATE) || size == -1 ||  mAudioDecoderDone) {
                            break;
                        }
                    }
                    if (bufferChunkSize >= 0) {
                        codec.queueInputBuffer(
                                index,
                                0,
                                bufferChunkSize,
                                presentationTime,
                                mAudioExtractor.getSampleFlags());
                    } else if (mAudioExtractorDone) {
                        if (VERBOSE) {
                            Log.d(TAG, "audio extractor: EOS");
                        }
                        codec.queueInputBuffer(
                                index,
                                0,
                                0,
                                0,
                                MediaCodec.BUFFER_FLAG_END_OF_STREAM);
                    }
                    if (mProgressListener != null) {
                        if (!mProgressListener.reportProgress((float) (mAudioExtractedTotalSize) / mFileSize)) {
                            // We are asked to stop reading the file. Returning immediately. The
                            // SoundFile object is invalid and should NOT be used afterward!
                            synchronized (this) {
                                mAudioDecoderDone = true;
                                notifyAll();
                            }
                        }
                    }
                    logState();
                    if (bufferChunkSize >= 0)
                        break;
                }
            }
            public void onOutputBufferAvailable(MediaCodec codec, int index, MediaCodec.BufferInfo info) {
                if (VERBOSE) {
                    Log.d(TAG, "audio decoder: returned output buffer: " + index);
                }
                if (VERBOSE) {
                    Log.d(TAG, "audio decoder: returned buffer of size " + info.size);
                }
                if ((info.flags & MediaCodec.BUFFER_FLAG_CODEC_CONFIG) != 0) {
                    if (VERBOSE) {
                        Log.d(TAG, "audio decoder: codec config buffer");
                    }

                    codec.releaseOutputBuffer(index, false);
                    return;
                }
                if (VERBOSE) {
                    Log.d(TAG, "audio decoder: returned buffer for time "
                            + info.presentationTimeUs);
                }
                mPendingAudioDecoderOutputBufferIndices.add(index);
                mPendingAudioDecoderOutputBufferInfos.add(info);
                mAudioDecodedFrameCount++;
                logState();
                decodeAudio();
            }
        });
        decoder.configure(inputFormat, null, null, 0);
        decoder.start();

        int duration = (int)Math.round(getDuration() / 1000000.0);
        sampleStep = Math.max(duration / 10, 1);

        return decoder;
    }

    private void ReadFile(String inputFile, Context context)
            throws FileNotFoundException,
            java.io.IOException, InvalidInputException {
        mAudioExtractor = new MediaExtractor();
        MediaFormat format = null;
        int i;

        Uri uri = Uri.parse(inputFile);

       //AssetFileDescriptor fileDescriptor = context.getContentResolver().openAssetFileDescriptor(uri , "r");
        mFileSize = 4000000;//(int)fileDescriptor.getLength();

        mAudioExtractor.setDataSource(context, uri, null);
        int numTracks = mAudioExtractor.getTrackCount();
        // find and select the first audio track present in the file.
        for (i = 0; i < numTracks; i++) {
            format = mAudioExtractor.getTrackFormat(i);
            if (format.getString(MediaFormat.KEY_MIME).startsWith("audio/")) {
                mAudioExtractor.selectTrack(i);
                break;
            }
        }
        if (i == numTracks) {
            throw new InvalidInputException("No audio track found in " + inputFile);
        }
        mChannels = format.getInteger(MediaFormat.KEY_CHANNEL_COUNT);
        mSampleRate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE);
        mDuration = format.getLong(MediaFormat.KEY_DURATION);

        // Set the size of the decoded samples buffer to 1MB (~6sec of a stereo stream at 44.1kHz).
        // For longer streams, the buffer size will be increased later on, calculating a rough
        // estimate of the total size needed to store all the samples in order to resize the buffer
        // only once.
        mDecodedBytes = ByteBuffer.allocate(1 << 20);
        Log.i(TAG, "start decoding");

        mPendingAudioDecoderOutputBufferIndices = new LinkedList<Integer>();
        mPendingAudioDecoderOutputBufferInfos = new LinkedList<MediaCodec.BufferInfo>();
        mAudioDecoder = createAudioDecoder(format);
        synchronized (this) {
            while (!mAudioDecoderDone) {
                try {
                    wait();
                } catch (InterruptedException ie) {
                }
            }
        }

        Log.i(TAG, "all set");
        mNumSamples = mDecodedBytes.position() / (mChannels * 2);  // One sample = 2 bytes.
        mDecodedBytes.rewind();
        mDecodedBytes.order(ByteOrder.LITTLE_ENDIAN);
        mDecodedData = simplifyData(mDecodedBytes, mDecodedBytes.remaining());

        mAudioExtractor.release();
        mAudioExtractor = null;
        mAudioDecoder.stop();
        mAudioDecoder.release();
        mAudioDecoder = null;

        Log.i(TAG, "all done");
    }

    public byte[] simplifyData(ByteBuffer buffer, int size) {
        int cursor = 0;
        byte[] samples = new byte[size / (4 * sampleStep)];
        int pos = 0;

        for (int i = 0; i < size; i++) {
            if (cursor % (sampleStep * 4) == 1) {
                byte val = (byte) Math.abs(buffer.get(i));

                // do a rudimentary dynamic range expansion
                if (val < 30) {
                    val = (byte) Math.round(val * 0.2);
                }
                if (val > 40) {
                    val = (byte) Math.round(val * 1.5);
                }

                if (pos < samples.length) {
                    samples[pos++] = val;
                }
            }
            cursor++;
        }

        return samples;
    }
}
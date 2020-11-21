/* MediaDecoder
 
   Author: Andrew Stubbs (based on some examples from the docs)
 
   This class opens a file, reads the first audio channel it finds, and returns raw audio data.
   
   Usage:
      MediaDecoder decoder = new MediaDecoder("myfile.m4a");
      short[] data;
      while ((data = decoder.readShortData()) != null) {
         // process data here
      }
  */

package co.gameline.mighty_plug_manager;

import java.io.Console;

import java.nio.ByteBuffer;
import java.nio.*;

import android.media.MediaCodec;
import android.media.MediaCodec.BufferInfo;
import android.media.MediaExtractor;
import android.media.MediaFormat;
import android.media.AudioFormat;

public class MediaDecoder {

    private final boolean DEBUG = false;

    private MediaExtractor extractor;
    private MediaCodec decoder;

    private MediaFormat inputFormat;
    
    private ByteBuffer[] inputBuffers;
    private boolean end_of_input_file;

    private ByteBuffer[] outputBuffers;
    private int outputBufferIndex = -1;

    public MediaDecoder(){}

    public void open(String inputFilename) {
        extractor = new MediaExtractor();

        try {
        extractor.setDataSource(inputFilename);
        }
        catch(Exception e)
        {
            System.out.println("Extractor.sedDataSource exception");
            System.out.println(e); 
            return;
        }
        
        if (DEBUG)
            System.out.println("Decoding track"); 
        // Select the first audio track we find.
        int numTracks = extractor.getTrackCount();

        if (DEBUG)
            System.out.println("tracks " + numTracks); 
        for (int i = 0; i < numTracks; ++i) {
            MediaFormat format = extractor.getTrackFormat(i);
            String mime = format.getString(MediaFormat.KEY_MIME);

            if (DEBUG)
                System.out.println("mime " + mime); 
            if (mime.startsWith("audio/")) {
                extractor.selectTrack(i);
                try {
                    decoder = MediaCodec.createDecoderByType(mime);
                }
                catch(Exception e)
                {
                    System.out.println("Extractor.selectTrack exception");
                    System.out.println(e); 
                    return;
                }
                
                decoder.configure(format, null, null, 0);

                /* when adding encoder, use these settings
                format.setInteger(MediaFormat.KEY_CHANNEL_COUNT, 1);
                format.setInteger(MediaFormat.KEY_SAMPLE_RATE, 8000);
                format.setInteger(MediaFormat.KEY_PCM_ENCODING, AudioFormat.ENCODING_PCM_8BIT);

                decoder.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE);*/
                inputFormat = format;
                break;
            }
        }
        
        if (decoder == null) {
            throw new IllegalArgumentException("No decoder for file format");
        }
        
        decoder.start();
        inputBuffers = decoder.getInputBuffers();
        outputBuffers = decoder.getOutputBuffers();
        end_of_input_file = false;
    }
    

    public void release()
    {
        extractor.release();
    }

    // Read the raw data from MediaCodec.
    // The caller should copy the data out of the ByteBuffer before calling this again
    // or else it may get overwritten.
    private BufferInfo readData() {
        if (decoder == null)
            return null;

        BufferInfo info = new BufferInfo();
        
        for (;;) {
            // Read data from the file into the codec.
            if (!end_of_input_file) {
                int inputBufferIndex = decoder.dequeueInputBuffer(10000);
                if (inputBufferIndex >= 0) {
                    int size = extractor.readSampleData(inputBuffers[inputBufferIndex], 0);
                    if (size < 0) {
                        // End Of File
                        decoder.queueInputBuffer(inputBufferIndex, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM);
                        end_of_input_file = true;
                        if (DEBUG)
                            System.out.println("EndOfFile");
                    } else {
                        decoder.queueInputBuffer(inputBufferIndex, 0, size, extractor.getSampleTime(), 0);
                        extractor.advance();
                    }
                }
            }

            // Read the output from the codec.
            if (outputBufferIndex >= 0)
                // Ensure that the data is placed at the start of the buffer
                outputBuffers[outputBufferIndex].position(0);
                
            outputBufferIndex = decoder.dequeueOutputBuffer(info, 10000);
            if (outputBufferIndex >= 0) {
                // Handle EOF
                if (info.flags != 0) {
                    if (DEBUG)
                        System.out.println("EndOfFile Output");
                    decoder.stop();
                    decoder.release();
                    decoder = null;
                    return null;
                }
                
                //release output buffer removed from here!
                
                return info;
                
            } else if (outputBufferIndex == MediaCodec.INFO_OUTPUT_BUFFERS_CHANGED) {
                // This usually happens once at the start of the file.
                if (DEBUG)
                    System.out.println("BuffersChanged");
                outputBuffers = decoder.getOutputBuffers();
            }
        }
    }

    private ByteBuffer currentBuffer()
    {
        return outputBuffers[outputBufferIndex];
    }
    private void releaseBuffer()
    {
        // Release the buffer so MediaCodec can use it again.
        // The data should stay there until the next time we are called.
        decoder.releaseOutputBuffer(outputBufferIndex, false);
    }
    
    // Return the Audio sample rate, in samples/sec.
    public int getSampleRate() {
        return inputFormat.getInteger(MediaFormat.KEY_SAMPLE_RATE);
    }

    public long getDuration() {
        return inputFormat.getLong(MediaFormat.KEY_DURATION);
    }
    
    // Read the raw audio data in 16-bit format
    // Returns null on EOF
    public byte[] readShortData() {
        BufferInfo info = readData();

        if (info==null)
            return null;

        ByteBuffer data = currentBuffer();
        
        if (data == null)
            return null;
        
        byte[] returnData = new byte[info.size];
         
        if (DEBUG) {
            System.out.println("buffer info " + info.size);
            System.out.println("buffer stuff " + data.position() + " " + data.capacity());
        }

        if (info.size>0)
            data.get(returnData);

        releaseBuffer();
        return returnData;
    }
}
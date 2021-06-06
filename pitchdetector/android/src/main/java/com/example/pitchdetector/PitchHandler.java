package com.example.pitchdetector;
import be.tarsos.dsp.pitch.Yin;
import be.tarsos.dsp.pitch.Yin;


public class PitchHandler{
    int SAMPLE_RATE = 0;
    float dominantPitch = 0;
    int SAMPLE_SIZE = 0;
    public PitchHandler(int SAMPLE_RATE , int SAMPLE_SIZE){
        this.SAMPLE_RATE = SAMPLE_RATE; 
        this.SAMPLE_SIZE = SAMPLE_SIZE;
    }
    public float getPitch(short[] audioPcm){
        float[] samples = this.shortToPcmArray(audioPcm);
        Yin yin = new Yin(this.SAMPLE_RATE , this.SAMPLE_SIZE);
        float pitchResult = yin.getPitch(samples).getPitch();
        return pitchResult;
    }

    public float getPitch(float[] audioPcm){
        Yin yin = new Yin(SAMPLE_RATE , SAMPLE_SIZE);
        float pitchResult = yin.getPitch(audioPcm).getPitch();
        return pitchResult;
    }

    public float[] shortToPcmArray(short[] pcm){
        float[] floaters = new float[pcm.length];
        for (int i = 0; i < pcm.length; i++) {
            floaters[i] = pcm[i];
        }
        return floaters;
    }
} 


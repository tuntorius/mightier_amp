import Flutter
import UIKit
import AVFoundation


class YIN{
    var sampleRate : Int;
    var sampleSize : Int;
    var yinBuffer : [Double];
    var threshold : Double;
    init( sampleRate : Int , sampleSize : Int ){
        self.sampleSize = sampleSize;
        self.sampleRate = sampleRate;
        self.yinBuffer = [Double](repeating : 0 , count :self.sampleSize / 2);
        self.threshold = 0.20;
    }

    func getPitch( audioBuffer : [Double]) -> Double{
        var tauEstimate : Int;
        var pitchInHertz : Double;
        self.difference(audioBuffer : audioBuffer);

        self.cumulativeMeanNormalizedDifference();

        tauEstimate = self.absoluteThreshold();

        if (tauEstimate != -1) {
            let betterTau : Double = self.parabolicInterpolation(tauEstimate : tauEstimate);

            // step 6
            // TODO Implement optimization for the AUBIO_YIN algorithm.
            // 0.77% => 0.5% error rate,
            // using the data of the YIN paper
            // bestLocalEstimate()

            // conversion to Hz
            pitchInHertz = Double(self.sampleRate) / betterTau;
        }
        else{
            pitchInHertz = -1.0;
        }
        return pitchInHertz

    }

    func difference(audioBuffer : [Double]){
        var index : Int;
        var tau : Int;
        var delta : Double;
        // for (tau = 0; tau < yinBuffer.length; tau++) {
        //     yinBuffer[tau] = 0;
        // }
        for tau in 1..<yinBuffer.count{
            for index in 0..<yinBuffer.count{
                delta = audioBuffer[index] -  audioBuffer[index + tau];
                yinBuffer[tau]+=delta*delta
            }
        }
    
    }

    func cumulativeMeanNormalizedDifference(){
        var tau : Int;
        yinBuffer[0] = 1.0;
        var runningSum:Double = 0.0;

        for tau in 1..<yinBuffer.count{
            runningSum += yinBuffer[tau]
            yinBuffer[tau] *= (Double(tau)/runningSum);
        }
        // int tau;
        // yinBuffer[0] = 1;
        // float runningSum = 0;
        // for (tau = 1; tau < yinBuffer.length; tau++) {
        //     runningSum += yinBuffer[tau];
        //     yinBuffer[tau] *= tau / runningSum;
        // }
    }

    func absoluteThreshold() -> Int{
        var tau : Int;
        var _tauMutable : Int = 0;
        // first two positions in yinBuffer are always 1
        // So start at the third (index 2)
        for tau in 2..<yinBuffer.count{
            if (yinBuffer[tau] < self.threshold) {
                _tauMutable = tau;
                while (_tauMutable + 1 < yinBuffer.count && yinBuffer[_tauMutable + 1] < yinBuffer[_tauMutable]) {
                    _tauMutable = _tauMutable + 1;
                }
                break;
            }
        }

        if (_tauMutable == yinBuffer.count || yinBuffer[_tauMutable] >= self.threshold) {
            _tauMutable = -1;
        }
        return _tauMutable;
    }

    func  parabolicInterpolation( tauEstimate : Int) -> Double{
        var betterTau:Double;
        var x0 : Int;
        var x2 : Int;

        if (tauEstimate < 1) {
            x0 = tauEstimate;
        } else {
            x0 = tauEstimate - 1;
        }
        if (tauEstimate + 1 < yinBuffer.count) {
            x2 = tauEstimate + 1;
        } else {
            x2 = tauEstimate;
        }



        if (x0 == tauEstimate) {
            if (yinBuffer[tauEstimate] <= yinBuffer[x2]) {
                betterTau = Double(tauEstimate);
            } else {
                betterTau = Double(x2);
            }
        } else if (x2 == tauEstimate) {
            if (yinBuffer[tauEstimate] <= yinBuffer[x0]) {
                betterTau = Double(tauEstimate);
            } else {
                betterTau = Double(x0);
            }
        }
        else {
            var s0 : Double = yinBuffer[x0];
            var s1 : Double = yinBuffer[tauEstimate];
            var s2 : Double = yinBuffer[x2];
            // fixed AUBIO implementation, thanks to Karl Helgason:
            // (2.0f * s1 - s2 - s0) was incorrectly multiplied with -1
            var karlHasson1:Double = (2.0 * s1 - s2 - s0);
            var karlHasson2:Double = Double(tauEstimate) ;
            betterTau = karlHasson2 + (s2 - s0) / (2.0 * karlHasson1);
        }
        return betterTau;
    }

}


var channel:FlutterMethodChannel!;// instance variable
public class SwiftPitchdetectorPlugin: NSObject, FlutterPlugin {
  var isRecording = false
  var hasPermissions = false
  var startTime: Date!
  var audioRecorder: AVAudioRecorder!
  var engine:AVAudioEngine!
    var sampleSize = 2048;
    var sampleRate = 22050;
    //var yin : YIN;
  public static func register(with registrar: FlutterPluginRegistrar) {
    channel = FlutterMethodChannel(name: "pitchdetector", binaryMessenger: registrar.messenger())
    let instance = SwiftPitchdetectorPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
        case "initializeValues":
            let dic = call.arguments as! [String : Any]
            self.sampleRate = dic["sampleRate"] as! Int;
            self.sampleSize = dic["sampleSize"] as! Int;
            
            break;
        case "startRecording":
            self.engine = AVAudioEngine();
            //let dic = call.arguments as! [String : Any]
            setupPcm();
            //result("start");
            break;
        case "stopRecording":
            // print("stop")
            // audioRecorder.stop()
            // audioRecorder = nil
            // let duration = Int(Date().timeIntervalSince(startTime as Date) * 1000)
            // isRecording = false
            // var recordingResult = [String : Any]()
            // recordingResult["duration"] = duration
            // recordingResult["path"] = mPath
            // recordingResult["audioOutputFormat"] = mExtension
            stopRecording();
            result("stop");
            break;
        case "isRecording":
            // print("isRecording")
            // result(isRecording)
            result(hasPermissions)
            break;
        default:
            result(FlutterMethodNotImplemented)
            break;
      }
    result(nil)
  }	
    func setupPcm(){
        if #available(iOS 9.0, *) {
            let inputNode = engine.inputNode;
            let inputFormat = inputNode.outputFormat(forBus: 0);
            let recordingFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: Double(self.sampleRate), channels: 1, interleaved: true);
            let formatConverter = AVAudioConverter(from:inputFormat , to : recordingFormat!)
            inputNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount(self.sampleSize), format: inputFormat){
                       (buffer , time) in
                       
                let pcmBuffer = AVAudioPCMBuffer(pcmFormat: recordingFormat!, frameCapacity: AVAudioFrameCount(self.sampleSize))
                       var error : NSError? = nil;
                       
                       let inputBlock: AVAudioConverterInputBlock = {
                           inNumPackets , outStatus in
                           outStatus.pointee = AVAudioConverterInputStatus.haveData
                           return buffer;
                       }
                       formatConverter?.convert(to: pcmBuffer!, error: &error,withInputFrom: inputBlock)
                if error != nil{
                    print(error!.localizedDescription)
                }
                else if let channelData = pcmBuffer!.int16ChannelData{
                    let channelDataPointer = channelData.pointee;
                    let channelData = stride(
                        from : 0,
                        to : Int(pcmBuffer!.frameLength),
                        by: buffer.stride ).map{ Double(channelDataPointer[$0]) }
                    var pitch = YIN(sampleRate:self.sampleRate,sampleSize:self.sampleSize).getPitch(audioBuffer: channelData);
                    channel.invokeMethod("getPitch", arguments: pitch);
                }
            }
            engine.prepare();
            do{
                try! engine.start();
            }
            catch{
                
            }
            // Fallback on earlier versions
        }
        else{
            print("not available")
        }
       
    }
  func stopRecording(){
//      isRecording =
    print("stopping pcm recording");
    try! engine.stop()
  }
}

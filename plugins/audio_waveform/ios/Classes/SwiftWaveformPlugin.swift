import Flutter
import AVFoundation

public class AudioWaveformPlugin: NSObject, FlutterPlugin {
  private var channel: FlutterMethodChannel?
  private var waveformExtractor: WaveformExtractor?
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.tuntori.audio_waveform", binaryMessenger: registrar.messenger())
    let instance = AudioWaveformPlugin()
    instance.channel = channel
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "open":	  
	  guard let args = call.arguments as? Dictionary<String, Any>,
			  let path = args["path"] as? String else {
		  result(FlutterError(code: "invalid_arguments", message: "Invalid arguments for method 'open'", details: nil))
		  return
		}
	  
	  waveformExtractor = WaveformExtractor()
	  waveformExtractor.open(path)
	  result(nil)
    case "next":
		guard let args = call.arguments as? Dictionary<String, Any>,
			  let frameCount = args["frameCount"] as? UInt32 else {
		  result(FlutterError(code: "invalid_arguments", message: "Invalid arguments for method 'next'", details: nil))
		  return
		}
		guard let waveformExtractor = waveformExtractor else {
			result(FlutterError(code: "decoder_unavailable", message: "You must open a file first", details: nil))
			return
		}
      
		if waveformExtractor != nil {
		  let buffer = waveformExtractor.readShortData(frameCount: AVAudioFrameCount(frameCount))
		  result(buffer)
		} else {
		  result(FlutterError(code: "decoder_unavailable", message: "You must open a file first", details: nil))
		}
    case "close":
      waveformExtractor?.release()
      waveformExtractor = nil
      result(nil)
    case "duration":
      guard let waveformExtractor = waveformExtractor else {
        result(FlutterError(code: "decoder_unavailable", message: "You must open a file first", details: nil))
        return
      }
      
      let duration = waveformExtractor.getDuration()
      result(duration)
    case "sampleRate":
      guard let waveformExtractor = waveformExtractor else {
        result(FlutterError(code: "decoder_unavailable", message: "You must open a file first", details: nil))
        return
      }
      
      let sampleRate = waveformExtractor.getSampleRate()
      result(sampleRate)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
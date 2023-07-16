import Flutter
import UIKit
import AVFoundation

enum AudioPlayerState: String {
  case idle
  case reachedEnd
}

public class SwiftAVPlayerPlugin: NSObject, FlutterPlugin {
  private var player: AVAudioPlayerNode?
  private var audioEngine: AVAudioEngine? 
  private var playerStateStreamHandler: FlutterEventSink?
  private var positionTimer: Timer?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "av_player", binaryMessenger: registrar.messenger())
    let eventChannel = FlutterEventChannel(name: "av_player/playerStateStream", binaryMessenger: registrar.messenger())
    let instance = YourPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    eventChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "setAudioFile":
        guard let path = call.arguments as? String else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid audio file path", details: nil))
          return
        }
        setAudioFile(path, result: result)
      case "play":
        play(result: result)
      case "pause":
        pause(result: result)
      case "stop":
        stop(result: result)
      case "setSpeed":
        guard let speed = call.arguments as? Double else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid speed value", details: nil))
          return
        }
        setSpeed(speed, result: result)
      case "setPitch":
        guard let pitch = call.arguments as? Double else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid pitch value", details: nil))
          return
        }
        setPitch(pitch, result: result)
      case "seek":
        guard let position = call.arguments as? Int else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid position value", details: nil))
          return
        }
        seek(position: position, result: result)
      default:
        result(FlutterMethodNotImplemented)
    }
  }

  private func setAudioFile(_ path: String, result: FlutterResult) {
    guard let url = URL(string: path) else {
      result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid audio file URL", details: nil))
      return
    }
    do {
      let audioFile = try AVAudioFile(forReading: url)
      let duration = Double(audioFile.length) / audioFile.fileFormat.sampleRate * 1000
    

      player = AVAudioPlayerNode()
      audioEngine = AVAudioEngine()
      audioEngine?.attach(player!)
      audioEngine?.connect(player!, to: audioEngine!.outputNode, format: audioFile.processingFormat)
      try audioEngine?.start()
      
      player?.scheduleFile(audioFile, at: nil, completionHandler: { [weak self] in
        self?.playerStateStreamHandler?(AudioPlayerState.reachedEnd.rawValue)
        self?.stopPositionTimer()
      })
      
      result(duration)
    } catch {
      result(FlutterError(code: "SET_AUDIO_FILE_ERROR", message: "Error setting audio file", details: nil))
    }
  }

  private func play(result: FlutterResult) {
    player?.play()
    startPositionTimer()
    result(nil)
  }

  private func pause(result: FlutterResult) {
    player?.pause()
    stopPositionTimer()
    result(nil)
  }

  private func stop(result: FlutterResult) {
    player?.stop()
    player?.currentTime = 0
    stopPositionTimer()
    result(nil)
  }

  private func setSpeed(_ speed: Double, result: FlutterResult) {
    player?.rate = Float(speed)
    result(nil)
  }

  private func setPitch(_ pitch: Double, result: FlutterResult) {
    guard let player = player else {
      result(FlutterError(code: "INVALID_STATE", message: "Audio player not initialized", details: nil))
      return
    }
    let pitchEffect = AVAudioUnitTimePitch()
    pitchEffect.pitch = Float(pitch)
    audioEngine?.attach(pitchEffect)
    audioEngine?.connect(player, to: pitchEffect, format: player.outputFormat(forBus: 0))
    audioEngine?.connect(pitchEffect, to: audioEngine!.outputNode, format: player.outputFormat(forBus: 0))
    result(nil)
  }

  private func seek(position: Int, result: FlutterResult) {
    let time = Double(position) / 1000.0
    player?.stop()
    player?.scheduleSegment(AVAudioFileBuffer(from: player!.file!, position: AVAudioFramePosition(time * player!.file!.fileFormat.sampleRate), length: 0), startingFrame: AVAudioFramePosition(0), frameCount: AVAudioFrameCount(player!.file!.length))
    player?.play()
    result(nil)
  }

  private func startPositionTimer() {
    stopPositionTimer()
    positionTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
      self?.sendPosition()
    }
  }

  private func stopPositionTimer() {
    positionTimer?.invalidate()
    positionTimer = nil
  }

  private func sendPosition() {
    guard let player = player else { return }
    let currentTime = player.playerTime(forNodeTime: player.lastRenderTime!)!.sampleTime
    let sampleRate = player.outputFormat(forBus: 0).sampleRate
    let position = Double(currentTime) / Double(sampleRate) * 1000.0
    playerStateStreamHandler?(Int(position))
  }
  extension SwiftAVPlayerPlugin: AVAudioPlayerDelegate {
	  public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
	    playerStateStreamHandler?(AudioPlayerState.reachedEnd.rawValue)
	    stopPositionTimer()
	  }
	
	  public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
	    print("Audio player decode error: \(error?.localizedDescription ?? "Unknown error")")
	  }
	}
}



extension SwiftAVPlayerPlugin: FlutterStreamHandler {
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    playerStateStreamHandler = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    playerStateStreamHandler = nil
    return nil
  }
}
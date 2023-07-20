import Flutter
import UIKit
import AVFoundation

enum AudioPlayerState: String {
  case idle
  case reachedEnd
}

public class SwiftAVPlayerPlugin: NSObject, FlutterPlugin {
  private var player: AVAudioPlayerNode?
  private var audioFile: AVAudioFile?
  private var audioEngine: AVAudioEngine?
    private var rateEffect: AVAudioUnitTimePitch?
  private var playerStateStreamHandler: FlutterEventSink?
  private var positionTimer: Timer?
    private var segmentStartFrame: AVAudioFramePosition?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "av_player", binaryMessenger: registrar.messenger())
    let eventChannel = FlutterEventChannel(name: "av_player/playerStateStream", binaryMessenger: registrar.messenger())
    let instance = SwiftAVPlayerPlugin()
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
      // Initialize the AVAudioSession
      let audioSession = AVAudioSession.sharedInstance()
        
      // Set the category for background audio playback
      try audioSession.setCategory(.playback, options: [.duckOthers])

      // Activate the AVAudioSession
      try audioSession.setActive(true)

      audioFile = try AVAudioFile(forReading: url)
      let durationSeconds = Double(audioFile!.length) / audioFile!.fileFormat.sampleRate
      let durationMilliseconds = Int(durationSeconds * 1000)
    

      player = AVAudioPlayerNode()
      audioEngine = AVAudioEngine()
      audioEngine?.attach(player!)
        rateEffect = AVAudioUnitTimePitch()
        rateEffect!.rate = 1
        rateEffect!.pitch = 0
        audioEngine?.attach(rateEffect!)
        audioEngine?.connect(player!, to: rateEffect!, format: audioFile!.processingFormat)
      audioEngine?.connect(rateEffect!, to: audioEngine!.outputNode, format: audioFile!.processingFormat)
      try audioEngine?.start()
      
//      player?.scheduleFile(audioFile!, at: nil, completionCallbackType: .dataPlayedBack, completionHandler: { [weak self] in
//        self?.playerStateStreamHandler?(AudioPlayerState.reachedEnd.rawValue)
//        self?.stopPositionTimer()
//        self?.deactivateAudioSession()
//      })
        
        player?.scheduleFile(audioFile!, at: nil, completionCallbackType: .dataPlayedBack) { _ in
            print("Done playing")
          //self.playerStateStreamHandler?(AudioPlayerState.reachedEnd.rawValue)
          //self.stopPositionTimer()
          //self.deactivateAudioSession()
        }
      
      result(durationMilliseconds)
    } catch {
        let errorMessage = "Error setting up audio: \(error.localizedDescription)"
        result(FlutterError(code: "SET_AUDIO_FILE_ERROR", message: errorMessage, details: nil))

    }
  }

  private func play(result: FlutterResult) {
    player?.play()
    startPositionTimer()
    activateAudioSession()
    result(nil)
  }

  private func pause(result: FlutterResult) {
    player?.pause()
    stopPositionTimer()
    deactivateAudioSession()
    result(nil)
  }

  private func stop(result: FlutterResult) {
    player?.stop()
    //player?.currentTime = 0
    stopPositionTimer()
    deactivateAudioSession()
    result(nil)
  }

  private func setSpeed(_ speed: Double, result: FlutterResult) {
      rateEffect?.rate = Float(speed)
    result(nil)
  }

  private func setPitch(_ pitch: Double, result: FlutterResult) {
      rateEffect?.pitch = Float(pitch)
      result(nil)
  }

  private func seek(position: Int, result: FlutterResult) {
    guard let player = player, let audioFile = audioFile else {
      result(FlutterError(code: "INVALID_STATE", message: "Audio player or audio file not initialized", details: nil))
      return
    }

    let time = Double(position) / 1000.0
    let sampleTime = AVAudioFramePosition(time * audioFile.fileFormat.sampleRate)
      
      // Remember the start frame position for calculating elapsed time
          segmentStartFrame = sampleTime

    // Seek to the desired position
    player.stop()
    player.scheduleSegment(audioFile, startingFrame: sampleTime, frameCount: AVAudioFrameCount(audioFile.length - sampleTime), at: nil)
    player.play()

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
//    guard let player = player else { return }
//    let currentTime = player.playerTime(forNodeTime: player.lastRenderTime!)!.sampleTime
//    let sampleRate = player.outputFormat(forBus: 0).sampleRate
//    let position = Double(currentTime) / Double(sampleRate) * 1000.0
//    playerStateStreamHandler?(Int(position))
      
      guard let player = player, let audioFile = audioFile else { return }

      // Get the current frame position within the audio file
      let currentFramePosition = player.playerTime(forNodeTime: player.lastRenderTime!)!.sampleTime

      // Calculate the elapsed frames within the segment
      let elapsedFrames: AVAudioFramePosition
      if let segmentStartFrame = segmentStartFrame {
          elapsedFrames = currentFramePosition + segmentStartFrame
      } else {
          elapsedFrames = currentFramePosition
      }
      
      // Calculate the elapsed time in seconds
      let elapsedTimeSeconds = Double(elapsedFrames) / audioFile.fileFormat.sampleRate

      // Convert elapsed time to milliseconds
      let position = Int(elapsedTimeSeconds * 1000)

      playerStateStreamHandler?(position)
      
  }

  func activateAudioSession() {
    do {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setActive(true)
    } catch {
        print("Error activating AVAudioSession: \(error)")
    }
  }

  func deactivateAudioSession() {
    do {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setActive(false)
    } catch {
        print("Error deactivating AVAudioSession: \(error)")
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

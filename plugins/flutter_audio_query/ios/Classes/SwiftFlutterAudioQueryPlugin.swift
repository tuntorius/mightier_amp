import Flutter
import UIKit

public class SwiftFlutterAudioQueryPlugin: NSObject, FlutterPlugin {

  let CHANNEL_NAME:String = "boaventura.com.devel.br.flutteraudioquery";
  let m_delegate = AudioQueryDelegate();

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "boaventura.com.devel.br.flutteraudioquery", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterAudioQueryPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let arguments = call.arguments as? [String: Any]
    let source = arguments!["source"] as? String
    if(source != nil){
        switch (source){
        case "artist":
            m_delegate.artistSourceHandler(call, result);

        case "album":
            m_delegate.albumSourceHandler(call, result);

        case "song":
            m_delegate.songSourceHandler(call, result);

        case "genre":
            m_delegate.genreSourceHandler(call, result);

        case "playlist":
            m_delegate.playlistSourceHandler(call, result);

        case "artwork":
            m_delegate.artworkSourceHandler(call, result);

        default:
            result(FlutterMethodNotImplemented)
        }
      }       else {
          result(FlutterMethodNotImplemented);
      }
    }
}

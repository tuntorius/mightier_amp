import Flutter
import UIKit
import AVFoundation
import MediaPlayer

public class SwiftAudioPickerPlugin: NSObject, FlutterPlugin, MPMediaPickerControllerDelegate {
    
    var _viewController : UIViewController?
    var _audioPickerController : MPMediaPickerController?
    var _flutterResult : FlutterResult?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "audio_picker", binaryMessenger: registrar.messenger())
        let viewController = UIApplication.shared.delegate?.window??.rootViewController
        let instance = SwiftAudioPickerPlugin(viewController: viewController)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    init(viewController: UIViewController?) {
        super.init()
        self._viewController = viewController
    }
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if(call.method == "pick_audio"){
            if (_flutterResult != nil){
                // Return an error
                result(nil)
            }
            
            _flutterResult = result
            openAudioPicker()
        }
    }
    
    func export(_ assetURL: URL, completionHandler: @escaping (_ fileURL: URL?, _ error: Error?) -> ()) {
        let asset = AVURLAsset(url: assetURL)
        
        guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            completionHandler(nil, ExportError.unableToCreateExporter)
            return
        }
        
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(NSUUID().uuidString)
            .appendingPathExtension("m4a")
        
        exporter.outputURL = fileURL
        exporter.outputFileType = AVFileType(rawValue: "com.apple.m4a-audio")
        
        exporter.exportAsynchronously {
            if exporter.status == .completed {
                completionHandler(fileURL, nil)
            } else {
                completionHandler(nil, exporter.error)
            }
        }
        
    }
    
    enum ExportError: Error {
        case unableToCreateExporter
    }
    
    public func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        mediaPicker.dismiss(animated: true, completion: nil)
        let mediaItem = mediaItemCollection.items.first
                
        if (mediaItem?.assetURL != nil){
            if let assetURL = mediaItem?.assetURL {
                export(assetURL) { fileURL, error in
                    guard let fileURL = fileURL, error == nil else {
                        print("export failed: \(String(describing: error))")
                        return
                    }
                                        
                    if let result = self._flutterResult {
                        print("\(fileURL.path)")
                        result(fileURL.path)
                    } else {
                        // Return an error
                        self._flutterResult?(nil)
                    }
                    
                }
            }
        } else {
            // Return an error
            self._flutterResult?(nil)
        }
        
    }
    
    public func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController)
    {   _flutterResult?(nil)
        _flutterResult = nil
        mediaPicker.dismiss(animated: true, completion: nil)
    }
    
    func openAudioPicker() {
        _audioPickerController = MPMediaPickerController.self(mediaTypes:MPMediaType.music)
        _audioPickerController?.delegate = self
        _audioPickerController?.showsCloudItems = false
        _audioPickerController?.allowsPickingMultipleItems = false
        _audioPickerController?.modalPresentationStyle = UIModalPresentationStyle.currentContext
        _viewController?.present(_audioPickerController!, animated: true, completion: nil)
    }
    
}

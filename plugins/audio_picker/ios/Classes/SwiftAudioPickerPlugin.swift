import Flutter
import UIKit
import AVFoundation
import MediaPlayer

public class SwiftAudioPickerPlugin: NSObject, FlutterPlugin, MPMediaPickerControllerDelegate, UIDocumentPickerDelegate {
    
    let bookmarkPrefix = "iosbm://"

    var _viewController : UIViewController?
    var _audioPickerController : MPMediaPickerController?
    var _flutterResult : FlutterResult?
    var _channel : FlutterMethodChannel?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "audio_picker", binaryMessenger: registrar.messenger())
        let viewController = UIApplication.shared.delegate?.window??.rootViewController
        let instance = SwiftAudioPickerPlugin(viewController: viewController)
        instance._channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    init(viewController: UIViewController?) {
        super.init()
        self._viewController = viewController
    }
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if(call.method == "pick_audio"){
            
            _flutterResult = result
            openAudioPicker(multiple:false)
        }
        if(call.method == "pick_audio_multiple") {

            _flutterResult = result
            openAudioPicker(multiple:true)
        }
        if(call.method == "pick_audio_file"){
            
            _flutterResult = result
            openFilePicker(multiple:false)
        }
        if(call.method == "pick_audio_file_multiple"){
            
            _flutterResult = result
            openFilePicker(multiple:true)
        }
        if (call.method=="pick_audio_bookmark_to_url")
        {
            _flutterResult = result;
            if let args = call.arguments as? [String: Any],
            let bookmark = args["bookmark"] as? String {
                bookmarkToUrl(from: bookmark)
            } else {
                result(FlutterError(code: "invalid_argument", message: "Invalid arguments", details: nil))
            }
            
        }
        if (call.method=="get_metadata") {
            if let args = call.arguments as? [String: Any],
            let assetUrl = args["assetUrl"] as? String {
                let metadata = getArtistAndTitle(from: assetUrl)
                result(metadata)
            } else {
                result(FlutterError(code: "invalid_argument", message: "Invalid arguments", details: nil))
            }
        }
    }

    enum ExportError: Error {
        case unableToCreateExporter
    }
    
    public func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        mediaPicker.dismiss(animated: true, completion: nil)

        let count = mediaItemCollection.count;
        if (count == 1) {
            let mediaItem = mediaItemCollection.items.first
            if (mediaItem?.assetURL != nil) {
                self._flutterResult?(mediaItem?.assetURL?.absoluteString)
            }
        }
        else {
            var uniquePaths = Set<String>()
            for item in mediaItemCollection.items {
                if let path = item.assetURL?.absoluteString {
                    uniquePaths.insert(path)
                }
            }
            let pathList = Array(uniquePaths)
            self._flutterResult?(pathList)
        }
    }

    public func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController)
    {   _flutterResult?(nil)
        _flutterResult = nil
        mediaPicker.dismiss(animated: true, completion: nil)
    }
    
    func openAudioPicker(multiple: Bool) {
        _audioPickerController = MPMediaPickerController.self(mediaTypes:MPMediaType.music)
        _audioPickerController?.delegate = self
        _audioPickerController?.showsCloudItems = true
        _audioPickerController?.showsItemsWithProtectedAssets = false
        _audioPickerController?.allowsPickingMultipleItems = multiple
        _audioPickerController?.modalPresentationStyle = UIModalPresentationStyle.currentContext
        _viewController?.present(_audioPickerController!, animated: true, completion: nil)
    }

    func openFilePicker(multiple: Bool) {
        // Present the UIDocumentPickerViewController
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.audio"], in: .open)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = multiple
        documentPicker.modalPresentationStyle = .formSheet
        _viewController?.present(documentPicker, animated: true, completion: nil)
    }

    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {

        var bookmarkURLs: [String] = []
        
        for url in urls {
            do {
                // Start accessing the security-scoped resource
                if url.startAccessingSecurityScopedResource() {
                    // Create a bookmark data for the URL
                    let bookmarkData = try url.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil)
                    // Convert the bookmark data to a base64 encoded string
                    let bookmarkString = bookmarkPrefix + bookmarkData.base64EncodedString()
                    // Append the bookmark string to the array
                    bookmarkURLs.append(bookmarkString)
                    
                    // Stop accessing the security-scoped resource
                    url.stopAccessingSecurityScopedResource()
                } else {
                    // Handle the case where access to the security-scoped resource is denied
                    // You can choose to skip this URL or handle the error accordingly
                }
            } catch {
                // Handle error
                print(error.localizedDescription)
            }
        }

        self._flutterResult?(bookmarkURLs)
    }

    func getArtistAndTitle(from assetUrl: String) -> [String: String] {
        if assetUrl.hasPrefix("iosbm://") {
            guard let url = getUrlFromBookmark(from: assetUrl) else {
                return ["artist": "", "title": ""]
            }
            
            if url.startAccessingSecurityScopedResource() {
                let asset = AVAsset(url: url)
                let metadata = asset.metadata
                
                var artist = ""
                var title = ""
                for item in metadata {
                    if let key = item.commonKey?.rawValue, let value = item.value {
                        if key == "title" {
                            title = value as? String ?? ""
                        } else if key == "artist" {
                            artist = value as? String ?? ""
                        }
                    }
                }
                
                url.stopAccessingSecurityScopedResource()
                if artist.isEmpty, title.isEmpty {
                    //if the track has no metadata - return the filename
                    //cause flutter can't access it and would use the bookmark b64 data
                    let fileName = url.deletingPathExtension().lastPathComponent
                    return ["artist": fileName, "title": ""]
                } else {
                    return ["artist": artist, "title": title]
                }
            }
        } else {
            let query = MPMediaQuery.songs()
            let predicate = MPMediaPropertyPredicate(value: assetUrl, forProperty: MPMediaItemPropertyPersistentID)
            query.addFilterPredicate(predicate)
            if let result = query.items?.first {
                let title = result.title ?? ""
                let artist = result.artist ?? ""
                return ["artist": artist, "title": title]
            }
        }
        return ["artist": "", "title": ""]
    }

    func getUrlFromBookmark(from bookmarkB64: String) -> URL? {
        var bookmarkString = bookmarkB64
            bookmarkString = bookmarkString.replacingOccurrences(of: bookmarkPrefix, with: "")
        if let bookmarkData = Data(base64Encoded: bookmarkString) {
            do {
                var isStale = false
                let url = try URL(resolvingBookmarkData: bookmarkData, options: [], relativeTo: nil, bookmarkDataIsStale: &isStale)
                
                if isStale {
                    let newBookmark = try url.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil)
                    let newBookmarkString = bookmarkPrefix + newBookmark.base64EncodedString()
                    _channel?.invokeMethod("updateBookmark", arguments: [bookmarkB64, newBookmarkString])
                }
                
                return url
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return nil
    }

    func bookmarkToUrl(from bookmarkString: String) {
        guard let url = getUrlFromBookmark(from: bookmarkString) else {
            return
        }
        
        if url.startAccessingSecurityScopedResource() {
            self._flutterResult?(url.absoluteString)
            url.stopAccessingSecurityScopedResource()
        }
    }
}

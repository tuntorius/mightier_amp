import Flutter
import UIKit

public class SwiftFilePickerPlugin: NSObject, FlutterPlugin, UIDocumentPickerDelegate {
  var documentPicker: UIDocumentPickerViewController?
  var result: FlutterResult?
  var fileContents: String?
  var isExporting = false

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "file_picker", binaryMessenger: registrar.messenger())
    let instance = SwiftFilePickerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    self.result = result
    
    if (call.method == "saveToFile") {
        if let args = call.arguments as? [String: Any], let contents = args["fileContents"] as? String, let fileName = args["fileName"] as? String {
            self.fileContents = contents
            openDocumentPicker(fileName: fileName)
        } else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        }
    } else if (call.method == "readFile") {
        readDocument(result: result)
    } else {
        result(FlutterMethodNotImplemented)
    }
  }

  func openDocumentPicker(fileName: String) {
    isExporting = true
    DispatchQueue.main.async {
        
        guard let jsonData = self.fileContents?.data(using: .utf8) else {
            print("Error converting string to data")
            return
        }
        let tempDirectoryURL = FileManager.default.temporaryDirectory

        let fileURL = tempDirectoryURL.appendingPathComponent(fileName).appendingPathExtension("json")

        do {
            try jsonData.write(to: fileURL)
        } catch {
            print("Error writing JSON data: \(error)")
            return
        }

        let documentPicker = UIDocumentPickerViewController(urls: [fileURL], in: .moveToService)
        documentPicker.delegate = self

        UIApplication.shared.keyWindow?.rootViewController?.present(documentPicker, animated: true, completion: nil)
    }
  }

  private func readDocument(result: @escaping FlutterResult) {
    isExporting = false
    let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.json"], in: .import)
    documentPicker.delegate = self
    documentPicker.modalPresentationStyle = .formSheet
    UIApplication.shared.keyWindow?.rootViewController?.present(documentPicker, animated: true)
  }

  public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    if isExporting == false {
        let fileURL = urls[0]
        let fileData: Data
        do {
            fileData = try Data(contentsOf: fileURL)
            let fileContents = String(data: fileData, encoding: .utf8)
            result?(fileContents)
        } catch {
            print("Error reading file: \(error.localizedDescription)")
            result?(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
        }
    }
  }


  public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    self.result?(false)
  }
}

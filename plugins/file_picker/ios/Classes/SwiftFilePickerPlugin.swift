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
        if let args = call.arguments as? [String: Any], let contents = args["fileContents"] as? String {
            self.fileContents = contents
            openDocumentPicker()
        } else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        }
    } else if (call.method == "readFile") {
        readDocument(result: result)
    } else {
        result(FlutterMethodNotImplemented)
    }
  }

  func openDocumentPicker() {
    isExporting = true
    DispatchQueue.main.async {
      let types = ["public.json"]
      let documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .exportToService)
      documentPicker.delegate = self
      UIApplication.shared.keyWindow?.rootViewController?.present(documentPicker, animated: true, completion: nil)
      self.documentPicker = documentPicker
    }
  }

  private func readDocument(result: @escaping FlutterResult) {
    isExporting = false
    let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
    documentPicker.delegate = self
    documentPicker.modalPresentationStyle = .formSheet
    UIApplication.shared.keyWindow?.rootViewController?.present(documentPicker, animated: true)
  }

  public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    if isExporting == false {
        // User has selected one or more documents to import
        if let url = urls.first {
          do {
            try self.fileContents?.write(to: url, atomically: true, encoding: .utf8)
            self.result?(true)
          } catch {
            self.result?(FlutterError(code: "ERROR_SAVING_FILE", message: "Error saving file: \(error)", details: nil))
          }
        } else {
          self.result?(false)
        }
    } else {
        // User has selected a destination to export the document
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

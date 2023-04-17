import Flutter
import UIKit
import AVFoundation
import MobileCoreServices

public class SwiftQrUtilsPlugin: NSObject, FlutterPlugin, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
fileprivate var result:FlutterResult?
fileprivate var qrcodeImage: CIImage!
    
  fileprivate  var captureSession = AVCaptureSession()
    
   fileprivate var videoPreviewLayer: AVCaptureVideoPreviewLayer?
   fileprivate   var qrCodeFrameView: UIView?
    var qrScanner: SwiftFlutterBarcodeScannerPlugin?
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.qr]

    var controller: FlutterViewController!

    init(cont: FlutterViewController, messenger: FlutterBinaryMessenger) {
          self.controller = cont;
          super.init();
      }
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.aeologic.adhoc.qr_utils", binaryMessenger: registrar.messenger())

    SwiftFlutterBarcodeScannerPlugin.initScanner()
    let app =  UIApplication.shared
    let controller : FlutterViewController = app.delegate!.window!!.rootViewController as! 	FlutterViewController;
      
      let instance = SwiftQrUtilsPlugin.init(cont: controller, messenger: registrar.messenger())
      
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
    self.result = result
            if (call.method == "scanQR") {
                    if #available(iOS 10.0, *) {
                        qrScanner = SwiftFlutterBarcodeScannerPlugin()
                        qrScanner?.showScanner(result: result)
                    }
            }
            else if (call.method == "scanImage") {
                self.openImagePicker()
            }
            else if (call.method == "generateQR") {
                let tempDataDict = call.arguments as? Dictionary<String, Any>
                let content = tempDataDict!["content"] as! String
                self.generateQR(text: content)
            }
  }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }

        controller!.dismiss(animated: true)
        
        if let features = detectQRCode(image), !features.isEmpty{
            for case let row as CIQRCodeFeature in features{
                print(row.messageString ?? "scan error")
                self.result!(row.messageString ?? "")
                return
            }
        }
        self.result!(nil)
    }
    
    func detectQRCode(_ image: UIImage?) -> [CIFeature]? {
        if let image = image, let ciImage = CIImage.init(image: image){
            var options: [String: Any]
            let context = CIContext()
            options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
            if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)){
                options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
            } else {
                options = [CIDetectorImageOrientation: 1]
            }
            let features = qrDetector?.features(in: ciImage, options: options)
            return features

        }
        return nil
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

extension SwiftQrUtilsPlugin {
    @available(iOS 10.0, *)
    @available(iOS 10.0, *)
    
    func openImagePicker() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = false
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        controller!.present(pickerController, animated: true)
    }

    func generateQR(text:String){
        if text == "" {
            return
        }
        let data = text.data(using: .isoLatin1, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
    
        filter!.setValue(data, forKey: "inputMessage")
        filter!.setValue("Q", forKey: "inputCorrectionLevel")
        
        qrcodeImage = filter!.outputImage
        displayQRCodeImage()
    }
    
    func displayQRCodeImage() {
        let scaleX = 263 / qrcodeImage.extent.size.width
        let scaleY = 263 / qrcodeImage.extent.size.height
        let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        let img:UIImage =  convert(cmage: transformedImage)
        let imageData: Data = img.pngData()!
        self.result!(imageData)
    }
    
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
}

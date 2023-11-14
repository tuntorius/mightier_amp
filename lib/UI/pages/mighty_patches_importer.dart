// import the necessary packages
/*
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/savePreset.dart';
import 'package:mighty_plug_manager/UI/widgets/common/nestedWillPopScope.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:qr_utils/qr_utils.dart';

// create a stateful widget for the page
class MightyPatchesPage extends StatefulWidget {
  const MightyPatchesPage({super.key});

  @override
  _MightyPatchesPageState createState() => _MightyPatchesPageState();
}

// create the state class for the widget
class _MightyPatchesPageState extends State<MightyPatchesPage> {
// create a web view controller
  late WebViewController _controller;
  bool _fromAppBar = false;

  @override
  void initState() {
    super.initState();

    _fromAppBar = false;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          _registerDOMChanged();
        },
        onProgress: (progress) {
          _addImportButtons();
        },
      ))
      ..addJavaScriptChannel(
        "flutter_inappwebview",
        onMessageReceived: (message) {
          // Handle the message received from JavaScript
          String jsonMessage = message.message;
          Map<String, dynamic> data = json.decode(jsonMessage);
          // Extract title and URL from the JSON data
          String title = data['title'];
          String imageUrl = data['imageUrl'];

          // Call your Flutter method with the title and image URL
          _importImage(imageUrl, title);
        },
      )
      ..addJavaScriptChannel("flutter_domchange", onMessageReceived: (message) {
        print("DOM Changed");
        _addImportButtons();
      });
    _home();
  }

  void _home() {
    _controller.loadRequest(Uri.parse('https://www.mightypatches.com/'));
  }

  void _registerDOMChanged() {
    const String script = '''
    var observeDOM = (function(){
        var MutationObserver = window.MutationObserver || window.WebKitMutationObserver;

        return function( obj, callback ) {
          if( !obj || obj.nodeType !== 1 ) return; 

          if( MutationObserver ){
            // define a new observer
            var mutationObserver = new MutationObserver(callback)

            // have the observer observe for changes in children
            mutationObserver.observe( obj, { childList:true, subtree:true })
            return mutationObserver
          }
          
          // browser support fallback
          else if( window.addEventListener ){
            obj.addEventListener('DOMNodeInserted', callback, false)
            obj.addEventListener('DOMNodeRemoved', callback, false)
          }
        }
      })()

      var observed = document.querySelector(".page-content, [data-elementor-type=single-post]");

      observeDOM(observed, function(m){
        flutter_domchange.postMessage("");
      });
    ''';

    _controller.runJavaScript(script);
  }

  void _addImportButtons() async {
    // Evaluate JavaScript to find elements and add import buttons
    const String script = '''

      function getSmallestSizeImageUrl(srcset) {
        // Split the srcset into individual URL-width pairs
        const pairs = srcset.split(',').map(pair => pair.trim().split(' '));

        // Find the pair with the smallest width
        const smallestPair = pairs.reduce((smallest, current) => {
          const currentWidth = parseInt(current[1], 10);
          const smallestWidth = parseInt(smallest[1], 10);
          return currentWidth < smallestWidth ? current : smallest;
        }, pairs[0]);

        // Return the URL from the smallest pair
        return smallestPair[0];
      }

      var elements = document.querySelectorAll(".page-content [data-elementor-type=jet-listing-items]:not(:has(.import-button)), [data-elementor-type=single-post]:not(:has(.import-button))");
      elements.forEach(function(element) {
        var imageWidget = element.querySelector(".elementor-widget-image");
        var imgElement = imageWidget.querySelector("img");
        //var imageUrl = imgElement.src;
        const srcset = imgElement.getAttribute('srcset');
        const imageUrl = getSmallestSizeImageUrl(srcset);

        var titleElement = element.querySelector(".elementor-page-title .elementor-heading-title,.page-content .elementor-heading-title");
        var title = titleElement.textContent;
        
        var importButton = document.createElement("a");
        importButton.href = "javascript:void(0);"; // Placeholder href, you can change this
        importButton.className = "import-button";
        importButton.style.position = "absolute";
        importButton.style.bottom = "0";
        importButton.style.right = "0";
        importButton.style.width = "50%";
        importButton.style.height = "50px";
        importButton.style.backgroundColor = "blue";
        importButton.style.color = "white";
        importButton.style.display = "flex";
        importButton.style.alignItems = "center";
        importButton.style.justifyContent = "center";
        importButton.innerHTML = "Import";
        
        importButton.onclick = function() {
          // Send title and image URL to Flutter using the JavascriptChannel
          var data = {
            "title": title,
            "imageUrl": imageUrl
          };
          flutter_inappwebview.postMessage(JSON.stringify(data));
        };
        
        imageWidget.appendChild(importButton);
      });
    ''';

    _controller.runJavaScript(script);
  }

// create a method to handle the import button click
  void _importImage(String imageUrl, String imageName) async {
// get the image data from the url using http stream
    print("opening stream");
    http.StreamedResponse response =
        await http.Client().send(http.Request('GET', Uri.parse(imageUrl)));
    print("Reading stream");
// get the byte data from the response stream
    List<int> byteData = await response.stream.toBytes();

    print("decoding QR");
// scan the image data using qr utils
    String? qrData = await QrUtils.scanImageFromData(byteData);

    print("Showing data");
// do something with the qr data, such as showing a dialog

    if (qrData != null) {
      var device = NuxDeviceControl.instance().device;

      var preset = device.setupDetachedPresetFromQRData(qrData);
      var saveDialog = SavePresetDialog(
          customName: imageName,
          customPreset: preset,
          device: device,
          confirmColor: Theme.of(context).hintColor);
      showDialog(
        context: context,
        builder: (BuildContext context) =>
            saveDialog.buildDialog(device, context),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return NestedWillPopScope(
      onWillPop: () async {
        if (_fromAppBar) return true;
        if (await _controller.canGoBack()) {
          _controller.goBack();
          return false;
        }
        return true;
      },
      child: SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Mighty Patches'),
              leading: IconButton(
                icon: Icon(Icons.adaptive.arrow_back),
                onPressed: () {
                  // Set the flag to true before popping the navigation
                  _fromAppBar = true;

                  Navigator.of(context).pop();
                },
              ),
              actions: [
                IconButton(onPressed: _home, icon: const Icon(Icons.home))
              ],
            ),
            body: WebViewWidget(controller: _controller)),
      ),
    );
  }
}
*/
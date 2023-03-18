import 'package:flutter/material.dart';

import '../../modules/cloud/cloudManager.dart';
import 'cloud_authentication.dart';
import 'toneshare_home.dart';

class ToneShare extends StatefulWidget {
  const ToneShare({super.key});

  @override
  State<ToneShare> createState() => _ToneShareState();

  static Future<void> startLoading(BuildContext context) async {
    return await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const SimpleDialog(
          elevation: 0.0,
          backgroundColor:
              Colors.black45, // can change this to your prefered color
          children: <Widget>[
            Center(
              child: CircularProgressIndicator(),
            )
          ],
        );
      },
    );
  }

  static Future<void> stopLoading(BuildContext context) async {
    Navigator.of(context).pop();
  }
}

class _ToneShareState extends State<ToneShare> {
  @override
  void initState() {
    super.initState();
    CloudManager.instance.addListener(_onAuthChange);
  }

  @override
  void dispose() {
    super.dispose();
    CloudManager.instance.removeListener(_onAuthChange);
  }

  void _onAuthChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    if (CloudManager.instance.signedIn) {
      page = ToneShareHome();
    } else {
      page = const CloudAuthentication();
    }

    return SafeArea(
        child: Scaffold(
      body: page,
    ));
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool isDeviceConnected;
  late Timer _timer;
  bool _dialogShown = false; // Flag to track if the dialog has been shown

  @override
  void initState() {
    super.initState();
    isDeviceConnected = true; // Assuming device is initially connected
    checkConnectivity();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      checkConnectivity();
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> checkConnectivity() async {
    final isConnected = await InternetConnectionChecker().hasConnection;
    setState(() {
      isDeviceConnected = isConnected;
    });
    if (!isConnected && !_dialogShown) {
      _dialogShown = true; // Set the flag to true to indicate the dialog has been shown
      showDialogBox();
    }
  }

  void showDialogBox() {
    showDialog<String>(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) => AlertDialog(
        title: const Text('No Connection'),
        content: const Text('Please check your internet connectivity'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              SystemNavigator.pop(); // Close the app
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isDeviceConnected
        ? WebviewScaffold(
      url: 'https://freshad.mpntraders.net/',
      withZoom: true,
      withLocalStorage: true,
      scrollBar: true,
      withJavascript: true,
    )
        : Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

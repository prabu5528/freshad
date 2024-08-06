import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:image_picker/image_picker.dart' as image_picker;


class WebViewMainPage extends StatefulWidget {
  const WebViewMainPage({super.key});

  @override
  State<WebViewMainPage> createState() => _WebViewMainPageState();
}

class _WebViewMainPageState extends State<WebViewMainPage> {
  late final WebViewController webViewController;
  int loadingPercentage = 0;

  @override
  void initState() {
    super.initState();

    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          setState(() {
            loadingPercentage = 0;
          });
        },
        onProgress: (progress) {
          setState(() {
            loadingPercentage = progress;
          });
        },
        onPageFinished: (url) {
          setState(() {
            loadingPercentage = 100;
          });
        },
        onNavigationRequest: (navigationRequest) {
          final String host = Uri.parse(navigationRequest.url).host;
          if (host.contains("youtube.com")) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Navigation to $host is blocked")));
            return NavigationDecision.prevent;
          } else {
            return NavigationDecision.navigate;
          }
        },
      ))
      ..loadRequest(
        Uri.parse('https://freshad.mpntraders.net/'),
      );
  }


  Future<bool> _onWillPop() async {
    // Check if the WebView can go back
    if (await webViewController.canGoBack()) {
      webViewController.goBack();
      return Future.value(false); // Prevent default back navigation
    } else {
      return (await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Exit App'),
          content: Text('Do you want to exit the app?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes'),
            ),
          ],
        ),
      )) ?? false; // Use default exit behavior if no more history
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Freshad',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
          centerTitle: true,
          backgroundColor: Colors.green[100],
        ),
        body: Stack(
          children: [
            WebViewWidget(
              controller: webViewController,
            ),
            if (loadingPercentage < 100)
              Center(
                child: CircularProgressIndicator(
                  value: loadingPercentage / 100.0,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

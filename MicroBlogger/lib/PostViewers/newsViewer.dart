import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../Components/Others/UIElements.dart';
import 'dart:io' show Platform;

class NewsViewer extends StatelessWidget {
  final link;
  const NewsViewer({Key key, this.link}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop()),
          title: Text("News Viewer"),
        ),
        body: (!Platform.isWindows)
            ? WebView(
                initialUrl: link,
                javascriptMode: JavascriptMode.unrestricted,
              )
            : ErrorPage(
                child: AlertDialog(
                  title: Text("Platform Unsupported"),
                  content: Text(
                      "As your target platform is Windows, this build of MicroBlogger does not support WebViewFunctionality. Please install or wait for a compatible build!"),
                  actions: [
                    FlatButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Close"))
                  ],
                ),
              ));
  }
}

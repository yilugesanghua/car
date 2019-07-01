import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:oktoast/oktoast.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Container(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: WebViewPage(),
      ),
    );
  }
}

class WebViewPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WebViewPageState();
  }
}

class WebViewPageState extends State<WebViewPage> {
  bool isLoading = true;
  Timer _timer;
  int progress = 0;
  WebViewController _webViewController;
  String _curUrl;

  static Future<void> pop() async {
    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  JavascriptChannel _alertJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toast',
        onMessageReceived: (JavascriptMessage message) {
          print("onMessageReceived  " + message.message);
        });
  }

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  void initState() {
    super.initState();

    _simulateProgress();
  }

  /// 模拟异步加载
  Future _simulateProgress() async {
    if (_timer == null) {
      _timer = Timer.periodic(Duration(milliseconds: 50), (time) {
        progress++;
        if (progress > 98) {
          _timer.cancel();
          _timer = null;
          return;
        } else {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () {
          if (_webViewController != null) {
            _webViewController.canGoBack().then((value) {
              if (value) {
                print("_webViewController  can   go back");
                _webViewController.goBack();
              } else {
                print("_webViewController  can not  go back");
//                Navigator.pop(context);
                pop();
              }
            });
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Flutter WebView example'),
            bottom: PreferredSize(
              child: _progressBar(),
              preferredSize: Size.fromHeight(2.0),
            ),
          ),
          body: Builder(builder: (BuildContext context) {
            return WebView(
              initialUrl: 'http://www.clwztc.com/wap/',
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _webViewController = webViewController;
                _controller.complete(webViewController);
              },
              javascriptChannels: <JavascriptChannel>[
                _alertJavascriptChannel(context),
              ].toSet(),
              navigationDelegate: (NavigationRequest request) {
                if (request != null && request.url.startsWith("tel:")) {
                  doCall(request.url);
                  return NavigationDecision.prevent;
                }
                if (request != null &&
                    request.url == "http://www.clwztc.com/wap/Book.asp") {
                  showToast("正在努力建设中...");
                  return NavigationDecision.prevent;
                }
                setState(() {
                  isLoading = true;
                  progress = 0;
                  _simulateProgress();
                });
                _curUrl = request.url;
                print('allowing navigation to $request');

                return NavigationDecision.navigate;
              },
              onPageFinished: (String url) {
                setState(() {
                  isLoading = false;
                });
                print('Page finished loading: $url');
              },
            );
          }),
        ));
  }

  doCall(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _progressBar() {
    print(progress);
    return SizedBox(
      height: isLoading ? 2 : 0,
      child: LinearProgressIndicator(
        value: isLoading ? progress / 100 : 1,
        backgroundColor: Color(0xfff3f3f3),
        valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
      ),
    );
  }
}

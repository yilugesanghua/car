import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Container(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
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
  String _curUrl ;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter WebView example'),
        bottom: PreferredSize(
          child: _progressBar(),
          preferredSize: Size.fromHeight(2.0),
        ),
      ),
      body: Builder(builder: (BuildContext context) {
        Future<bool> _onWillPop() =>
            _showMessage(context, "信息", "返回键被点击，将要返回第一页");
        return WillPopScope(
          onWillPop: _onWillPop,
          child: WebView(
            initialUrl: 'http://www.clwztc.com/',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _webViewController = webViewController;
              _controller.complete(webViewController);
            },
            javascriptChannels: <JavascriptChannel>[
              _alertJavascriptChannel(context),
            ].toSet(),
            navigationDelegate: (NavigationRequest request) {
              setState(() {
                isLoading = true;
                progress = 0;
                _simulateProgress();
              });
              _curUrl=request.url;
              print('allowing navigation to $request');
              return NavigationDecision.navigate;
            },
            onPageFinished: (String url) {
              setState(() {
                isLoading = false;
              });
              print('Page finished loading: $url');
            },
          ),
        );
      }),
    );
  }

  Future<void> _showMessage(
      BuildContext context, String title, String message) {
    if(_curUrl=="http://www.clwztc.com/wap"){
      new Future.value(true);
    }else{
      if (_webViewController != null) {
        _webViewController.canGoBack().then((value) {
          if (value) {
            _webViewController.goBack();
          } else {
            new Future.value(true);
          }
        });
      }
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

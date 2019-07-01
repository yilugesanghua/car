//import 'dart:async';
//
//import 'package:flutter/material.dart';
//import 'package:flutter_native_web/flutter_native_web.dart';
//import 'package:flutter/gestures.dart';
//import 'package:flutter/foundation.dart';
//
//class WebPage extends StatefulWidget {
//  @override
//  State<StatefulWidget> createState() {
//    return WebPageState();
//  }
//}
//
//class WebPageState extends State<WebPage> {
//  WebController webController;
//  bool isLoading = true;
//  Timer _timer;
//  int progress = 0;
//
//  @override
//  void initState() {
//    super.initState();
//    _simulateProgress();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    FlutterNativeWeb flutterWebView = new FlutterNativeWeb(
//      onWebCreated: onWebCreated,
//      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
//        Factory<OneSequenceGestureRecognizer>(
//          () => TapGestureRecognizer(),
//        ),
//      ].toSet(),
//    );
//
//    return new MaterialApp(
//      home: new Scaffold(
//          appBar: new AppBar(
//
////            title: const Text('Native WebView as Widget'),
//            bottom: PreferredSize(
//              child: _progressBar(),
//              preferredSize: Size.fromHeight(2.0),
//            ),
//          ),
//          body: flutterWebView),
//    );
//  }
//
//  void onWebCreated(webController) {
//    this.webController = webController;
//    this.webController.loadUrl("http://www.clwztc.com/wap/");
//    this.webController.onPageStarted.listen((url) {
//      print("Loading $url");
//      setState(() {
//        isLoading = true;
//        progress = 0;
//        _simulateProgress();
//      });
//    });
//    this.webController.onPageFinished.listen((url) {
//      print("Finished loading $url");
//      setState(() {
//        isLoading = false;
//      });
//    });
//  }
//
//  /// 模拟异步加载
//  Future _simulateProgress() async {
//    if (_timer == null) {
//      _timer = Timer.periodic(Duration(milliseconds: 50), (time) {
//        progress++;
//        if (progress > 98) {
//          _timer.cancel();
//          _timer = null;
//          return;
//        } else {
//          setState(() {});
//        }
//      });
//    }
//  }
//
//  Widget _progressBar() {
//    print(progress);
//    return SizedBox(
//      height: isLoading ? 2 : 0,
//      child: LinearProgressIndicator(
//        value: isLoading ? progress / 100 : 1,
//        backgroundColor: Color(0xfff3f3f3),
//        valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
//      ),
//    );
//  }
//
//  @override
//  void dispose() {
//    super.dispose();
//    if (_timer != null) {
//      _timer.cancel();
//      _timer = null;
//    }
//  }
//}

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

class PaymentWebView extends StatefulWidget {
  @override
  _PaymentWebViewState createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("포트원 결제"),
      ),
      body: WebView(
        initialUrl: 'about:blank',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller = webViewController;
          _loadHtmlFromAssets();  // HTML 파일 로드
        },
        navigationDelegate: (NavigationRequest request) {
          if (request.url.startsWith("success://payment")) {
            String? impUid = Uri.parse(request.url).queryParameters['imp_uid'];
            String? merchantUid = Uri.parse(request.url).queryParameters['merchant_uid'];
            Navigator.pop(context, {'success': true, 'imp_uid': impUid, 'merchant_uid': merchantUid});
            return NavigationDecision.prevent;
          } else if (request.url.startsWith("fail://payment")) {
            String? errorMsg = Uri.parse(request.url).queryParameters['error_msg'];
            Navigator.pop(context, {'success': false, 'error_msg': errorMsg});
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );
  }

  // HTML 파일을 로드하는 함수
  _loadHtmlFromAssets() async {
    String fileHtmlContents = await DefaultAssetBundle.of(context).loadString("assets/payment_page.html");
    _controller.loadUrl(Uri.dataFromString(
      fileHtmlContents,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }
}

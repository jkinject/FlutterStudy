import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

bool _registered = false;

Widget buildCoinpanWebView() {
  if (!_registered) {
    _registered = true;
    ui_web.platformViewRegistry.registerViewFactory(
      'coinpan-iframe',
      (int viewId) {
        final iframe = web.document.createElement('iframe') as web.HTMLIFrameElement
          ..src = 'https://coinpan.com'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        return iframe;
      },
    );
  }
  return const HtmlElementView(viewType: 'coinpan-iframe');
}

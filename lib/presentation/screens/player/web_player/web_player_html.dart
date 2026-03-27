// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

Widget buildWebPlayer(String url) {
  final viewId = 'hls-player-${url.hashCode}';

  ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
    final video = html.VideoElement()
      ..id = 'video_${url.hashCode}'
      ..style.width = '100%'
      ..style.height = '100%'
      ..controls = true
      ..autoplay = true;

    if (url.contains('.m3u8')) {
      final script = html.ScriptElement()
        ..src = 'https://cdn.jsdelivr.net/npm/hls.js@latest'
        ..type = 'text/javascript';

      script.onLoad.listen((_) {
        final innerScript = html.ScriptElement()
          ..type = 'text/javascript'
          ..text = '''
          var video = document.getElementById('video_${url.hashCode}');
          if (Hls.isSupported()) {
            var hls = new Hls({
               debug: false,
            });
            hls.loadSource('$url');
            hls.attachMedia(video);
            hls.on(Hls.Events.MANIFEST_PARSED, function() {
              video.play();
            });
          }
          else if (video.canPlayType('application/vnd.apple.mpegurl')) {
            video.src = '$url';
            video.addEventListener('loadedmetadata', function() {
              video.play();
            });
          }
        ''';
        html.document.head?.append(innerScript);
      });
      html.document.head?.append(script);
    } else {
       video.src = url;
    }

    return video;
  });

  return HtmlElementView(viewType: viewId);
}

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
//https://api.flutter.dev/flutter/dart-ui/PictureRecorder-class.html

class NameDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Stroked text as border.
        Text(
          'Greetings, planet!',
          style: TextStyle(
            fontSize: 40,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 6
              ..color = Colors.blue[700]!,
          ),
        ),
        // Solid text as fill.
        Text(
          'Greetings, planet!',
          style: TextStyle(
            fontSize: 40,
            color: Colors.grey[300],
          ),
        ),
      ],
    );
  }

  Future<Marker> createMarker(double lat, double long, String name) async {
    Uint8List uint8list = await getBytesFromName(name);
    return Marker(
        markerId: MarkerId(name),
        position: LatLng(lat, long),
        icon: BitmapDescriptor.fromBytes(uint8list));
  }

  Future<Uint8List> getBytesFromName(String name) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final textPainter = TextPainter(
      text: TextSpan(
          text: name, style: TextStyle(fontSize: 20, color: Colors.grey[300])),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(minWidth: 0, maxWidth: 500);
    final centerX = (500 - textPainter.width) / 2;
    final centerY = (500 - textPainter.height) / 2;
    final offset = Offset(centerX, centerY);

    textPainter.paint(canvas, offset);

    final recording = recorder.endRecording();
    final image = await recording.toImage(500, 300);
    final ByteData? bd = await image.toByteData(format: ui.ImageByteFormat.png);
    return bd!.buffer.asUint8List();
  }
}

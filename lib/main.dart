import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'ocr_engine.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(OcrApp());
}

class OcrApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "UCM Card Scanner Demo",
      home: Scaffold(
        appBar: AppBar(
          title: Text("UCM Card Scanner Demo"),
        ),
        body: CameraPage(),
      ),
    );
  }
}

class CameraPage extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraPage> {
  CameraController controller;
  bool _isScanBusy = false;
  Timer _timer;
  String _textDetected = "no text detected...";

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }

      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return Column(children: [
      Expanded(child: _cameraPreviewWidget()),
      Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          Text(_textDetected, style: TextStyle(fontStyle: FontStyle.italic,fontSize: 18),)
        ]),
      Container(
        height: 100,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
          MaterialButton(
              child: Text("Scan card"),
              textColor: Colors.white,
              color: Colors.blue,
              onPressed: () async {
                  await controller.startImageStream((CameraImage availableImage) {
                    OcrManager.scanText(availableImage).then((textVision) {
                      setState(() {
                        _textDetected = textVision ?? "";
                      });
                      controller.stopImageStream();

                    }).catchError((error) {
                    });
                  });
              }),
        ]),
      ),
    ]);
  }

  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      );
    }
  }
}

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  late Future<void> _initializeControllerFuture;
  bool _isCameraInitialized = false;
  XFile? _capturedImage;

  // final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  /// 初始化摄像头
  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _cameraController = CameraController(
        cameras![0], // 使用后置摄像头
        ResolutionPreset.high,
      );

      _initializeControllerFuture = _cameraController!.initialize();
      await _initializeControllerFuture;
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;

      if (_cameraController!.value.isTakingPicture) {
        return;
      }

      // 拍照并返回图片文件
      XFile picture = await _cameraController!.takePicture();

      setState(() {
        _capturedImage = picture;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF006A4E),
      ),
      backgroundColor: Colors.green,
      body: _isCameraInitialized
          ? Stack(
              children: [
                if (_capturedImage == null) CameraPreview(_cameraController!),
                if (_capturedImage != null)
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Image.file(File(_capturedImage!.path)),
                    ),
                  ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FloatingActionButton(
                      onPressed: () {
                        _takePicture();
                      },
                      backgroundColor: const Color(0xFFB3CB39),
                      child: Icon(Icons.camera),
                    ),
                  ),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}

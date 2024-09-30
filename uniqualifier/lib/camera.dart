import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CameraScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final textRecognizer = TextRecognizer();
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
        cameras![1], // 使用后置摄像头
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
    super.dispose();
    _cameraController?.dispose();
  }

  Future<void> _takePicture() async {
    print("照相");
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
      final inputImage = InputImage.fromFile(File(picture.path));
      final recognizedText = await textRecognizer.processImage(inputImage);
      print("识别的题目为" + recognizedText.text + "|||||||||||||||||");
      // 这个地方需要加入上传并返回答案
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_sharp,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context); // 返回到上一个页面
          },
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: _isCameraInitialized
          ? Stack(
              children: [
                // 相机预览界面
                CameraPreview(_cameraController!),
                // 拍照按钮
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FloatingActionButton(
                      onPressed: () {
                        _takePicture();
                      },
                      backgroundColor: Colors.white,
                      child: Icon(Icons.camera, color: Colors.black),
                    ),
                  ),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()), // 相机加载时显示进度条
    );
  }
}

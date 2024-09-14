import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  XFile? _galleryImage;
  XFile? _capturedImage; // 保存拍摄的图片

  bool _isSearching = false; // 是否处于搜索状态

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController = CameraController(_cameras![0], ResolutionPreset.high);
      await _cameraController!.initialize();
      setState(() {
        _pages.addAll([
          Center(child: Text('History Page')),
          _buildCameraPreview(), // Search page (camera)
          Center(child: Text('Ask a teacher Page')),
        ]);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _galleryImage = image;
    });
  }

  // 拍照功能
  Future<void> _takePicture() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      XFile image = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = image; // 保存拍摄的图片
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (_currentIndex != 1) {
        _isSearching = false;
      }
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Widget _buildCameraPreview() {
    return Center(child: Text('Search Page'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Screen'),
      ),
      body: _pages.isNotEmpty
          ? _pages[_currentIndex]
          : Center(child: CircularProgressIndicator()),
      bottomNavigationBar: BottomAppBar(
        shape: _isSearching ? null : CircularNotchedRectangle(), // 切换底部的形状
        notchMargin: _isSearching ? 0.0 : 10.0, // 根据是否处于搜索状态切换notchMargin
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              iconSize: 30.0,
              icon: Icon(Icons.history),
              tooltip: "History",
              color: _currentIndex == 0 ? Colors.green : Colors.grey,
              onPressed: () {
                _onItemTapped(0);
              },
            ),
            SizedBox(width: 40), // 中间留出位置给浮动按钮
            IconButton(
              iconSize: 30.0,
              icon: Icon(Icons.school),
              tooltip: "Ask a teacher",
              color: _currentIndex == 2 ? Colors.green : Colors.grey,
              onPressed: () {
                _onItemTapped(2);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedContainer(
        duration: Duration(milliseconds: 500), // 动画持续时间
        curve: Curves.linear, // 动画曲线
        width: _isSearching ? 80.0 : 80.0, // 当处于搜索状态时，按钮宽度变为0
        height: _isSearching ? 200.0 : 80.0, // 高度也随之变化
        child: FloatingActionButton(
          onPressed: () {
            if (_currentIndex == 1) {
              // 如果当前在 Search Page，拍照
              _takePicture();
            } else {
              // 切换到 Search Page
              setState(() {
                _isSearching = true; // 切换到搜索状态
                Navigator.pushNamed(context, "/home/camera");
              });
            }
          },
          child: Icon(Icons.camera_alt_outlined, size: 40), // 调整图标大小以适应按钮
          tooltip: 'Search',
          elevation: 5.0,
          shape: CircleBorder(), // 圆形
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

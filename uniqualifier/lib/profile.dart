import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image; // 选取的头像文件

  // 选择图片的功能
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Profile"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 显示用户选择的头像，如果没有选择，则显示默认图标
            _image == null
                ? IconButton(
                    icon: Icon(Icons.person),
                    onPressed: _pickImage,
                    iconSize: 100,
                  )
                : GestureDetector(
                    onTap: _pickImage, // 处理点击事件
                    child: Container(
                      child: Image.file(
                        _image!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
            SizedBox(height: 20),
            // 按钮用来选择头像
          ],
        ),
      ),
    );
  }
}

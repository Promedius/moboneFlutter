import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ImageUploader(),
    );
  }
}

class ImageUploader extends StatefulWidget {
  const ImageUploader({super.key});

  @override
  State<ImageUploader> createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _outputImage;
  bool _isUploading = false;

  Future<void> _getImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = pickedFile;
      _uploadImage();
    });
  }

  Future<void> _getImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = pickedFile;
      _uploadImage();
    });
  }

  Future<void> _uploadImage() async {
    setState(() {
      _isUploading = true;
    });
    // API Endpoint
    Uri uri = Uri.parse("http://35.193.54.6:8000/run");

    var request = http.Request('POST', uri);
    request.headers['Content-Type'] = 'application/octet-stream';
    
      // 이미지 로드
    img.Image? image = img.decodeImage(File(_image!.path).readAsBytesSync());

    // EXIF 회전 정보 가져오기
    img.Image? orientedImage = img.bakeOrientation(image!);

    // 이미지 회전된 상태로 업로드
    request.bodyBytes = img.encodePng(orientedImage);
    
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var output = await response.stream.toBytes();
      setState(() {
        _outputImage = output;
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile bonesup demo'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: _getImageFromCamera,
              ),
              IconButton(
                icon: const Icon(Icons.photo),
                onPressed: _getImageFromGallery,
              ),
              _image == null
                  ? const Text('No image selected.')
                  : Image.file(File(_image!.path)),
              _isUploading
                  ? const CircularProgressIndicator()
                  : _outputImage == null
                      ? const Text('No output image yet.')
                      : Image.memory(_outputImage!),
            ],
          ),
        ),
      )
    );
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImageUploader(),
    );
  }
}

class ImageUploader extends StatefulWidget {
  @override
  _ImageUploaderState createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _outputImage;

  Future<void> _getImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = pickedFile;
    });
  }

  Future<void> _getImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = pickedFile;
    });
  }

  Future<void> _uploadImage() async {
    // API Endpoint
    Uri uri = Uri.parse("http://35.223.91.153:8000/run");

    var request = http.Request('POST', uri);
    request.headers['Content-Type'] = 'application/octet-stream';
    request.bodyBytes = await _image!.readAsBytes();

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var output = await response.stream.toBytes();
      setState(() {
        _outputImage = output;
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
                icon: Icon(Icons.camera_alt),
                onPressed: _getImageFromCamera,
              ),
              IconButton(
                icon: Icon(Icons.photo),
                onPressed: _getImageFromGallery,
              ),
              _image == null
                  ? const Text('No image selected.')
                  : Image.file(File(_image!.path)),
              TextButton(
                onPressed: _uploadImage,
                child: const Text('Upload Image'),
              ),
              _outputImage == null
                  ? const Text('No output image yet.')
                  : Image.memory(_outputImage!),
            ],
          ),
        ),
      )
    );
  }
}

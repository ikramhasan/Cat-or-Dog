import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = true;
  final picker = ImagePicker();
  File image;
  List output;

  @override
  void initState() {
    loadModel().then((value) {
      setState(() {});
    });
    super.initState();
  }

  classifyImage(File image) async {
    var tfOutput = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    setState(() {
      output = tfOutput;
      loading = false;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: 'assets/model_unquant.tflite',
      labels: 'assets/labels.txt',
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  pickImage({ImageSource source}) async {
    var chosenImage = await picker.getImage(source: source);

    if (chosenImage == null) return null;

    setState(() {
      image = File(chosenImage.path);
    });

    classifyImage(image);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    print(height);
    print(width);

    buildImagePickerButton({String text, Function onTap}) {
      return InkWell(
        onTap: onTap,
        child: Container(
          width: width * 0.763,
          height: height * 0.071,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Color(0xFF630000),
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.comfortaa(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    buildCatOrDogColumn() {
      return Positioned(
        top: 60,
        child: Column(
          children: [
            Container(
              height: 300,
              width: width,
              child: Image.asset(
                'assets/cover.png',
                fit: BoxFit.cover,
              ),
            ),
            Text(
              'Cat or Dog?',
              style: GoogleFonts.comfortaa(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: Color(0xFF630000),
              ),
            ),
          ],
        ),
      );
    }

    buildClassifiedImageColumn() {
      double confidence = 0.0;
      if (output != null) {
        confidence = output[0]['confidence'].toDouble();
        confidence = confidence * 100;
      }
      return Positioned(
        top: 60,
        child: Column(
          children: [
            Container(
              color: Colors.red,
              height: 400,
              width: 350,
              child: Image.file(
                image,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 30),
            output != null
                ? Text(
                    'I\'m ${confidence.round()}% sure it\'s a ${output[0]['label']}',
                    style: GoogleFonts.comfortaa(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF630000),
                    ),
                  )
                : Container(),
          ],
        ),
      );
    }

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          image == null ? buildCatOrDogColumn() : buildClassifiedImageColumn(),
          Positioned(
            bottom: 130,
            child: buildImagePickerButton(
              text: 'Take a photo',
              onTap: () => pickImage(source: ImageSource.camera),
            ),
          ),
          Positioned(
            bottom: 60,
            child: buildImagePickerButton(
              text: 'Choose from gallery',
              onTap: () => pickImage(source: ImageSource.gallery),
            ),
          ),
        ],
      ),
    );
  }
}

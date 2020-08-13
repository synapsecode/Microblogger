import 'dart:convert';
import 'dart:io';
import 'package:MicroBlogger/Backend/datastore.dart';
import 'package:MicroBlogger/Components/Global/globalcomponents.dart';
import 'package:MicroBlogger/Composers/blogComposer.dart';
import 'package:MicroBlogger/Composers/timelineComposer.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../Backend/server.dart';

/// Widget to capture and crop the image
class ImageCapture extends StatefulWidget {
  String imageFor;
  Map preExistingState;
  ImageCapture({this.imageFor, this.preExistingState});
  createState() => _ImageCaptureState();
}

class _ImageCaptureState extends State<ImageCapture> {
  /// Active image file
  File _imageFile;

  /// Cropper plugin
  Future<void> _cropImage() async {
    File cropped = await ImageCropper.cropImage(
        sourcePath: _imageFile.path,

        // ratioX: 1.0,
        // ratioY: 1.0,
        // maxWidth: 512,
        // maxHeight: 512,
        toolbarColor: Colors.purple,
        toolbarWidgetColor: Colors.white,
        toolbarTitle: 'Crop It');

    setState(() {
      _imageFile = cropped ?? _imageFile;
    });
  }

  /// Select an image via gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);

    setState(() {
      _imageFile = selected;
    });
  }

  /// Remove image
  void _clear() {
    setState(() => _imageFile = null);
  }

  @override
  Widget build(BuildContext context) {
    print("IMAGE FOR: ${widget.imageFor}");
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
        title: Text("Upload Image"),
      ),
      // Select an image from the camera or gallery
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.photo_camera),
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            IconButton(
              icon: Icon(Icons.photo_library),
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ),

      // Preview the image and crop it
      body: ListView(
        children: <Widget>[
          if (_imageFile != null) ...[
            Container(
              margin: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white12, width: 3.0),
                color: Colors.black38,
              ),
              child: SizedBox(
                  height: 400.0, width: 400.0, child: Image.file(_imageFile)),
            ),
            Row(
              children: <Widget>[
                FlatButton(
                  child: Icon(Icons.crop),
                  onPressed: _cropImage,
                  // onPressed: () {
                  //   Fluttertoast.showToast(
                  //     msg: "The Cropping Feature has been disabled",
                  //     backgroundColor: Color.fromARGB(200, 220, 20, 60),
                  //   );
                  // },
                ),
                FlatButton(
                  child: Icon(Icons.clear),
                  onPressed: _clear,
                ),
              ],
            ),
            Uploader(widget.imageFor,
                preExistingState: widget.preExistingState, file: _imageFile)
          ]
        ],
      ),
    );
  }
}

class Uploader extends StatefulWidget {
  final file;
  final imageFor;
  Map preExistingState;
  Uploader(this.imageFor, {this.file, this.preExistingState});
  @override
  _UploaderState createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  // final FirebaseStorage _storage =
  //     FirebaseStorage(storageBucket: 'gs://fireship-lessons.appspot.com');
  // StorageUploadTask _uploadTask;

  /// Starts an upload task
  void _startUpload() async {
    print(widget.file);
    if (widget.imageFor == 'PROFILE') {
      await addDisplayPicture(widget.file);
      Navigator.pushReplacementNamed(context, '/ProfilePage');
    } else if (widget.imageFor == 'BACKGROUND') {
      await addBackground(widget.file);
      Navigator.pushReplacementNamed(context, '/ProfilePage');
    } else if (widget.imageFor == 'BLOGCOVER') {
      String link = await addCoverPicture(widget.file);
      print("The Generated Link is: $link");
      widget.preExistingState['cover'] = link;
      print("IUP: ${widget.preExistingState}");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BlogComposer(
                    preExistingState: widget.preExistingState,
                  )));
    } else if (widget.imageFor == 'TIMELINECOVER') {
      String link = await addCoverPicture(widget.file);
      print("The Generated Link is: $link");
      widget.preExistingState['cover'] = link;
      print("IUP: ${widget.preExistingState}");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TimelineComposer(
                    preExistingState: widget.preExistingState,
                  )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: FlatButton.icon(
        padding: EdgeInsets.all(10.0),
        color: Color.fromARGB(200, 220, 20, 60),
        label: Text('Upload to Server'),
        icon: Icon(Icons.cloud_upload),
        onPressed: _startUpload,
      ),
    );
    // return CirclularLoader();
    // //if (_uploadTask != null) {
    //   /// Manage the task state and event subscription with a StreamBuilder
    //   // return StreamBuilder<StorageTaskEvent>(
    //   //     stream: _uploadTask.events,
    //   //     builder: (_, snapshot) {
    //   //       var event = snapshot?.data?.snapshot;

    //   //       double progressPercent = event != null
    //   //           ? event.bytesTransferred / event.totalByteCount
    //   //           : 0;

    //   //       return Column(
    //   //         children: [
    //   //           if (_uploadTask.isComplete) Text('🎉🎉🎉'),

    //   //           if (_uploadTask.isPaused)
    //   //             FlatButton(
    //   //               child: Icon(Icons.play_arrow),
    //   //               onPressed: _uploadTask.resume,
    //   //             ),

    //   //           if (_uploadTask.isInProgress)
    //   //             FlatButton(
    //   //               child: Icon(Icons.pause),
    //   //               onPressed: _uploadTask.pause,
    //   //             ),

    //   //           // Progress bar
    //   //           LinearProgressIndicator(value: progressPercent),
    //   //           Text('${(progressPercent * 100).toStringAsFixed(2)} % '),
    //   //         ],
    //   //       );
    //   //     });
    // } else {
    //   // Allows user to decide when to start the upload

    // }
  }
}
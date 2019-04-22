import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

// A screen that allows users to take a picture using a given camera
class TakePictureScreen extends StatefulWidget {
  final getUrls;
  final CameraDescription camera;
  final save;

  const TakePictureScreen({
    Key key,
    @required
    this.getUrls,
    this.camera,
    this.save
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // Create a CameraController to display the current output from the Camera
    _controller = CameraController(
      // Get a specific camera from the list of available cameras
      widget.camera,
      // Define the resolution to use
      ResolutionPreset.medium,
    );

    // Initialize the controller. This returns a Future
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Make sure to dispose of the controller when the Widget is disposed
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take a picture')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        // Provide an onPressed callback
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure the camera is initialized
            await _initializeControllerFuture;

            // Construct the path where the image should be saved using the path
            // package.
            final imageName = '${DateTime.now()}.png';
            final path = join(
              // Store the picture in the temp directory. Find
              // the temp directory using the `path_provider` plugin.
              (await getTemporaryDirectory()).path,
              imageName,
            );

            // Attempt to take a picture and log where it's been saved
            await _controller.takePicture(path);

            // If the picture was taken, display it on a new screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                    getUrls: widget.getUrls,
                    imagePath: path,
                    imageName: imageName,
                    save: widget.save),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
      ),
    );
  }
}

// A Widget that displays the picture taken by the user
class DisplayPictureScreen extends StatelessWidget {
  final getUrls;
  final String imagePath;
  final String imageName;
  final save;

  const DisplayPictureScreen({Key key, this.getUrls, this.imagePath, this.imageName, this.save}) : super(key: key);

  saveToStorage() async {
    print(imageName);
    var urls;
    urls = getUrls();
    print(urls.split(','));
    print(urls.split(',').length);
    if (urls.split(',').length < 4) {
      try {
        final StorageReference storageRef = FirebaseStorage.instance.ref().child(imageName);
        final StorageUploadTask uploadTask = storageRef.putFile(File(imagePath));
        final StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
        String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
        save(downloadUrl);
        print(downloadUrl);
        return { "result": true, "message": '' };
      } catch (e) {
        print(e);
        return { "result": false, "message": "Error saving pictures." };
      }
    } else {
      return { "result": false, "message": "You can only attach 4 pictures."};
    }
  }


// user defined function
  void _showDialog(BuildContext context, String message) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Error"),
          content: new Text(message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image
      body: Builder(
    builder: (context) =>
      Column(
      children: <Widget>[
        Image.file(File(imagePath)),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new RaisedButton(
                child: new Text('Cancel',
                style: new TextStyle(fontSize: 20.0)),
                onPressed: () {
                  Navigator.pop(context);
                }),
              new RaisedButton(
                child: new Text('Save',
                style: new TextStyle(fontSize: 20.0)),
                onPressed: () {
                   saveToStorage().then((res) {
                     print(res["result"]);
                     if( res["result"] ) {
                       final snackBar = SnackBar(
                           content: Text('Saved successfully!'),
                           duration: new Duration(minutes: 5),
                           action: SnackBarAction(
                             label: 'Return to take more pictures',
                             onPressed: () {
                               Navigator.pop(context);
                             },
                           )
                       );
                       Scaffold.of(context).showSnackBar(snackBar);
                     } else {
                       _showDialog(context, res["message"]);
                     }
                   });
              }),
    ])])
    ));
  }
}
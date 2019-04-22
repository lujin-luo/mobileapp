import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:camera/camera.dart';
import 'camera_page.dart';

class CreatePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => new _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {

  final formKey = new GlobalKey<FormState>();

  String _title;
  String _price;
  String _description;
  String _urls='';


  Future<bool> validateAndSave() async {
    final form = formKey.currentState;
    if ( form.validate() ) {
      form.save();
      print('Form is valid. Title: $_title, price: $_price, description: $_description, urls: $_urls');
      return Firestore.instance
          .collection('jgarage')
          .add({
            "title": _title,
            "price": _price,
            "description": _description,
            "urls": _urls
          })
          .then((result) => true)
          .catchError((err) => false);
    } else {
      print('Form is invalid');
      return false;
    }
  }

  Future<CameraDescription> getCamera() async {
    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

    // Get a specific camera from the list of available cameras
    final firstCamera = cameras.first;

    return firstCamera;
  }

  void addImageUrls(String urls) {
    setState(() {
      if(_urls == '') {
        _urls = urls;
      } else {
        _urls = _urls + ',' + urls;
      }
    });
  }

  String getImageUrls() {
    return _urls;
  }

  Widget _buildImage(BuildContext context, int index) {
    return Card(
      child: Column(
        children: <Widget>[
          Image.network(_urls.split(',')[index].toString())
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Add a product'),
        ),
        body: Builder(
            builder: (context) =>
                Center(
                    child: new Container(
                        padding: EdgeInsets.only(
                            top: 16.0, bottom: 20.0, left: 16.0, right: 16.0),
                        child: new Form(
                          key: formKey,
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              new TextFormField(
                                decoration: new InputDecoration(
                                    hintText: 'Enter title of the item'),
                                validator: (value) =>
                                value.isEmpty
                                    ? 'title cannot be empty'
                                    : null,
                                onSaved: (value) => _title = value,
                              ),
                              new TextFormField(
                                decoration: new InputDecoration(
                                    hintText: 'Enter price'),
                                validator: (value) =>
                                value.isEmpty
                                    ? 'price cannot be empty'
                                    : null,
                                onSaved: (value) => _price = value,
                              ),
                              new TextFormField(
                                decoration: new InputDecoration(
                                    hintText: 'Enter description of the item',
                                    contentPadding: const EdgeInsets.only(
                                        top: 16.0)),
                                onSaved: (value) => _description = value,
                              ),
                              new Row(
                                children: <Widget>[
                                  Expanded(
                                    child: new RaisedButton(
                                        child: new Text('Take a picture',
                                            style: new TextStyle(fontSize: 20.0)),
                                        onPressed: () async {
                                          CameraDescription firstCamera = await getCamera();
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => TakePictureScreen(
                                                      getUrls: getImageUrls,
                                                      camera: firstCamera,
                                                      save: addImageUrls)));
                                        }
                                    ),
                                  ),
                                  Expanded(
                                    child: new RaisedButton(
                                      child: new Text('Post',
                                          style: new TextStyle(fontSize: 20.0)),
                                      onPressed: () {
                                        validateAndSave().then((result) {
                                          print({"result": result});
                                          if(result) {
                                            final snackBar = SnackBar(
                                                content: Text('Creation success!'),
                                                duration: new Duration(minutes: 5),
                                                action: SnackBarAction(
                                                  label: 'Return to homepage',
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                )
                                            );
                                            Scaffold.of(context).showSnackBar(snackBar);
                                          }
                                        });
                                      },
                                    )
                                  ),
                                  ]),
                              Expanded(
                                  child: new ListView.builder(
                                    itemBuilder: _buildImage,
                                    itemCount: _urls.split(',').length,
                                  )
                              )
                            ]
                          ),
                        )
                    )
            )
        )
    );
  }
}


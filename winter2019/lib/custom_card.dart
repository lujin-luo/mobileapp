import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  CustomCard({@required this.title, this.price, this.description, this.urls});

  final title;
  final price;
  final description;
  final urls;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: new GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DisplayDetailsScreen(
                  title: title,
                  price: price.toString(),
                  description: description,
                  urls: urls,
              ),
            ),
          );
        },
          child: Container(
              padding: const EdgeInsets.only(top: 5.0),
              child: Column(
                children: <Widget>[
                  Text(title),
                  Text(price.toString()),
                  Text(description),
                ],
              ))
          ),
    );
  }
}

class DisplayDetailsScreen extends StatelessWidget {
  final title;
  final price;
  final description;
  final urls;

  const DisplayDetailsScreen({Key key, this.title, this.price, this.description, this.urls}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(title: Text('Display details')),
        body: ListView(
            padding: const EdgeInsets.only(top: 5.0),
          children: <Widget>[
            Text("Title: " + title),
            Text("Price: " + price.toString()),
            Text("Description: " + description),
            Column(
              children: urls.split(',').map<Widget>((url) {
                return Image.network(url.toString());
              }).toList(),
          ),
        ]
        )
    );
  }

}
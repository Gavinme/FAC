import 'package:example/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:pikachu_fac/pikachu_fac.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FAC Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ViewModelStoreProxyWidget(child: HomePageWidget()),
    );
  }
}

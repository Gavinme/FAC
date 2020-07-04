import 'package:flutter/material.dart';
import 'package:flutter_jetpack/flutter_jetpack.dart';

void main() {
  runApp(ViewModelPage(MyApp())); //页面使用顶级元素进行包裹
}

///数据层
class CountBean {
  int counter = 0;
}

///ViewModel层 用来桥接model和UI
class CountViewModel with ViewModel {
  var liveData = LiveData<CountBean>(CountBean());
}

///UI层
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('MyApp => build');
    ViewModelProvider.of(context).register(CountViewModel());
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'JetPack Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    print('MyHomePage => build');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You have pushed the button this many times:'),
            ViewModelProvider.of(context)
                .get<CountViewModel>()
                .liveData
                .observe(
              (ctx, value) {
                //建立数据和UI的绑定关系
                print('build');
                return Text('${value.counter}');
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ViewModelProvider.of(context)
            .get<CountViewModel>()
            .liveData
            .setValue((state) {
          //通过泛型获取页面全局model，并刷新UI
          state.counter++;
          print('${state.counter}');
        }),
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

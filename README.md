# flutter_architecture

### 关于flutter_architecture

flutter_architecture是一个Flutter页面架构组件，使用很类似谷歌的Android Architecture Component（AAC）组件;
如果你是Android开发者，相信你会快速上手并享受这样的开发过程！

相比InheritedWidget/Provider/BLoC，flutter_architecture更像一个页面框架和设计，注重关注点分离和代码分层，采用VM*的方式进行架构；同时在建立数据和UI的绑定更为轻量，当然flutter_architecture也支持和Provider一样的状态管理功能。


### 为什么使用flutter_architecture

##### 常见的架构原则

- 分离关注点

要遵循的最重要的原则是分离关注点。一种常见的错误是在Widget中编写所有代码。这些基于界面的类应仅包含处理界面和操作系统交互的逻辑。您应尽可能使这些类保持精简，这样可以避免许多与生命周期相关的问题。
您应尽可能使这些类保持精简，这样可以避免许多与生命周期相关的问题。

- 通过模型驱动界面
另一个重要原则是您应该通过模型驱动界面（最好是持久性模型）。模型是负责处理应用数据的组件。它们独立于应用中的 Widget
 对象和应用组件，因此不受应用的生命周期以及相关的关注点的影响

##### 收益 

- 加速开发
- 消除样板代码
- 构建高质量的强大应用

![architecture](https://developer.android.google.cn/topic/libraries/architecture/images/final-architecture.png)

### 使用

- 定义数据

```
///数据层
class CountBean {
  int counter = 0;
}
```

- 定义逻辑层


```
///ViewModel层 用来桥接model和UI
class CountViewModel with ViewModel {
  var liveData = LiveData<CountBean>(CountBean());
 //数据操作和逻辑处理
}

```

- 建立数据和UI的绑定关系


```

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {

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
```
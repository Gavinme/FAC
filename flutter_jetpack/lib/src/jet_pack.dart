import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'get_it.dart';

///顶级页面元素，实现了当前页面ViewModel装载和卸载
class ViewModelPage extends StatelessWidget {
  final Widget child;

  const ViewModelPage(
    this.child, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ViewModelStore>(
          create: (_) => ViewModelStore(),
          dispose: (context, value) {
            value.clear();
          },
        )
      ],
      child: child,
    );
  }
}

class ViewModelStore {
  GetIt viewModelGet;

  ViewModelStore() {
    viewModelGet = GetIt.asNewInstance();
  }

  clear() {
//    viewModelGet.unregister(disposingFunction: (value) {
//
//    });
  }

  register<T>(T viewModel) {
    viewModelGet.registerSingleton(
      viewModel,
    );
  }

  get<T>() {
//    if (viewModelGet.get<T>() != null) {
//      //register 此处能否提供AOP实现
//    } else {
//      return viewModelGet.get<T>();
//    }
    return viewModelGet.get<T>();
  }
}

class ViewModel {
  void onCleared() {}
}

class ViewModelProvider {
  static ViewModelStore of(BuildContext context) {
    return Provider.of<ViewModelStore>(context);
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///页面组件，实现了当前页面ViewModel装载和卸载
class ViewModelStoreProxyWidget extends StatelessWidget {
  final Widget child;

  const ViewModelStoreProxyWidget({
    this.child,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<_ViewModelStore>(
          create: (_) => _ViewModelStore(context),
          dispose: (context, value) {
            value._clear();
          },
        )
      ],
      child: child,
    );
  }
}

class _ViewModelStore {
  final _factories = Map<Type, dynamic>();

  /// the ones that get registered by name.
  final _factoriesByName = Map<String, dynamic>();

  BuildContext context;

  _ViewModelStore(this.context);

  static _ViewModelStore _of(BuildContext context) {
    try {
      return Provider.of<_ViewModelStore>(context, listen: false);
    } catch (e) {
      debugPrint('当前节点找不到对应ViewModelStore，请确认是否注册ViewModelStoreProxyWidget或context对象是否正确');
      if (kDebugMode) throw e;
    }
  }

  _clear() {
    _factories.values.forEach((value) {
      (value as ViewModel).onCleared();
    });
    _factoriesByName.values.forEach((value) {
      (value as ViewModel).onCleared();
    });
    _factories.clear();
    _factoriesByName.clear();
  }

  bool isRegister<T extends ViewModel>(T viewModel, {String instanceName}) {
    if (instanceName != null) {
      return _factoriesByName.containsKey(instanceName);
    } else {
      return _factories.containsKey(T);
    }
  }

  ///泛型务必要加上
  ///如果不想使用该方法进行注册view model 请直接使用 [get]
  T register<T extends ViewModel>(T viewModel, {String instanceName}) {
    if (instanceName != null) {
      if (_factoriesByName.containsKey(instanceName)) {
        return _factoriesByName[instanceName];
      } else {
        print('register viewModel: $viewModel instanceName: $instanceName');
        viewModel.appContext = context;
        _factoriesByName[instanceName] = viewModel;
        return _factoriesByName[instanceName];
      }
    } else {
      if (_factories.containsKey(T)) {
        return _factories[T];
      } else {
        print('register viewModel: $viewModel instanceName: $instanceName');
        viewModel.appContext = context;
        _factories[T] = viewModel;
        return _factories[T];
      }
    }
  }

  ///不清楚页面是否注册对应 view model 时，需要显示传入一个builder
  ///如果是使用代理穿透，不要穿任何builder，因为会默认在拦截处，实例化一个view model
  T get<T extends ViewModel>({T Function() builder, String instanceName}) {
    if (builder != null) {
      if (instanceName != null) {
        return register(builder(), instanceName: instanceName);
      } else {
        return register(builder());
      }
    } else {
      if (instanceName != null) {
        return _factoriesByName[instanceName];
      } else {
        return _factories[T];
      }
    }
  }
}

abstract class ViewModel {
  ///只允许使用navigation等与element无关的调用
  BuildContext appContext;

  void onCleared() {}

  ///传入对应的ViewModel泛型
  ///[builder] 实例化view model
  ///
  /// 1. 取当前嵌套页面组件VM type数据 [ancestorOfType]=false
  /// 2. 取根页面组件VM type数据 [ancestorOfType]=true&&[builder]==null
  /// 3. 取当前页面存在VM type数据 [ancestorOfType]=false
  static VM of<VM extends ViewModel>(BuildContext context,
      {VM Function() builder, String instance, bool ancestorOfType = false}) {
    VM vm;
    _ViewModelStore viewModelStore;
    viewModelStore = _ViewModelStore._of(context);
    vm = viewModelStore?.get<VM>(builder: builder, instanceName: instance);
    if (ancestorOfType) {
      while (viewModelStore != null) {
        vm = viewModelStore.get<VM>(builder: builder, instanceName: instance);
        viewModelStore = _ViewModelStore._of(viewModelStore.context);
      }
    } else {
      while (viewModelStore != null || vm == null) {
        if (viewModelStore != null) {
          vm = viewModelStore.get<VM>(builder: builder, instanceName: instance);
          if (vm != null) break;
          viewModelStore = _ViewModelStore._of(viewModelStore.context);
        }
      }
    }
    assert(vm != null, 'do you forget register the viewModel ${vm.runtimeType} in embed pager or top pager?');
    return vm;
  }
}

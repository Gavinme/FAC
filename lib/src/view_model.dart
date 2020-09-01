import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///页面组件，实现了当前页面ViewModel装载和卸载
///使用方式如，
/// ViewModelStoreProxyWidget(child: HomePageWidget())
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
  /// stores all [ViewModel] that get registered by Type
  final _factories = Map<Type, dynamic>();

  /// the ones that get registered by name.
  final _factoriesByName = Map<String, dynamic>();

  ///ViewModelStoreProxy Element
  BuildContext _vmsElement;

  _ViewModelStore(this._vmsElement);

  static _ViewModelStore _of(BuildContext context) {
    try {
      return Provider.of<_ViewModelStore>(context, listen: false);
    } catch (e) {
      debugPrint(
          '当前节点找不到对应ViewModelStore，确认context对象是否已被销毁或ViewModelStoreProxyWidget未注册');
      return null;
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

  ///校验[viewModel]是否在当前页面store中
  ///[instanceName] 同类型实例，按名称在页面store中进行索引
  bool isRegister<T extends ViewModel>(T viewModel, {String instanceName}) {
    if (instanceName != null) {
      return _factoriesByName.containsKey(instanceName);
    } else {
      return _factories.containsKey(T);
    }
  }

  ///泛型务必要加上
  ///如果不想使用该方法进行注册view model 请直接使用 [get]
  T _register<T extends ViewModel>(T viewModel, {String instanceName}) {
    if (instanceName != null) {
      if (_factoriesByName.containsKey(instanceName)) {
        return _factoriesByName[instanceName];
      } else {
        print('register viewModel: $viewModel instanceName: $instanceName');
        viewModel.appContext = _vmsElement;
        _factoriesByName[instanceName] = viewModel;
        return _factoriesByName[instanceName];
      }
    } else {
      if (_factories.containsKey(T)) {
        return _factories[T];
      } else {
        print('register viewModel: $viewModel instanceName: $instanceName');
        viewModel.appContext = _vmsElement;
        _factories[T] = viewModel;
        return _factories[T];
      }
    }
  }

  ///不清楚页面是否注册对应 view model 时，需要显示传入一个builder
  ///如果是使用代理穿透，不要穿任何builder，因为会默认在拦截处，实例化一个view model
  ///为了便于开发者使用或避免引起分歧 [builder]为必须需参数，因为本身不会带来开销
  T get<T extends ViewModel>(
      {@required T Function() builder, String instanceName}) {
    assert(builder != null, "builder is null,builder must be instantiation!");
    if (builder != null) {
      if (instanceName != null) {
        return _register(builder(), instanceName: instanceName);
      } else {
        return _register(builder());
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

///用来构建FAC框架中ViewModel层，所有与页面store状态管理和通信，请在ViewModel子类中实现
///建议，页面中的数据（LiveState）通过ViewModel来进行管理，这样能保证最大的解耦和页面相关的状态（数据）可被观察
///
///{@tool sample}
/// ```dart
///    class PageViewModel extends ViewModel {
///    LiveState<PageModel> pageModel = LiveState<PageModel>(PageModel());
///
///    static PageViewModel get(BuildContext context) {
///        return ViewModel.of<PageViewModel>(
///        context,
///        builder: () => PageViewModel(),
///        );
///    }
///
///    void onCountClick(BuildContext context) {
///        PageViewModel.get(context).pageModel.setState((value, _) {
///        _.state.count++;
///        });
///    }
///
///    }
/// ```
///{@end-tool}
abstract class ViewModel {
  ///只允许使用navigation等与element无关的调用
  ///[ViewModelStoreProxyWidget]对应的Element
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
    _ViewModelStore viewModelStore = _ViewModelStore._of(context);
    assert(viewModelStore != null, '当前节点获取store不正确，是否页面未注册VMS！');

    if (viewModelStore == null) {
      // release 破罐子破摔
      return builder();
    }
    vm = viewModelStore?.get<VM>(builder: builder, instanceName: instance);
    if (ancestorOfType) {
      //获取树形分支顶级元素的store
      while (viewModelStore != null) {
        vm = viewModelStore.get<VM>(builder: builder, instanceName: instance);
        viewModelStore = _ViewModelStore._of(viewModelStore._vmsElement);
      }
      debugPrint('获取树形分支顶级元素的VM实例');
    } else {
      while (viewModelStore != null || vm == null) {
        if (viewModelStore != null) {
          vm = viewModelStore.get<VM>(builder: builder, instanceName: instance);
          if (vm != null) break;
          viewModelStore = _ViewModelStore._of(viewModelStore._vmsElement);
        }
      }
    }
    assert(vm != null,
        'do you forget register the viewModel ${vm.runtimeType} in embed pager or top pager?');
    return vm;
  }
}

extension FacViewModelExtension on BuildContext {
  VM viewModel<VM extends ViewModel>() => ViewModel.of<VM>(this);
}

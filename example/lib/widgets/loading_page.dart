import 'package:example/widgets/staged_page_view.dart';
import 'package:flutter/material.dart';
import 'package:pikachu_fac/pikachu_fac.dart';

typedef OnRetryClick();
typedef OnInvokeLoaded();
typedef Widget ContentBuilder(_PageModel model, BuildContext context);

///对外跨组件刷新接口 [FacPageViewModel]
///使用LoadingPageWidget挂载在widget tree后，可以通过FacPageViewModel提供的接口进行状态更新
///
///{@tool sample}
///
/// 使用下面的方式控制页面的loading状态
///
///```dart
/// FacPageViewModel.get(context, instance: instance).setLoading();
///```
/// {@end-tool}
///
///
///{@tool sample}
///使用下面的方式传入页面数据的初始化操作onInvokeLoaded（比如通过网络请求或页面透传的方式）
///
///```dart
///LoadingPageWidget(
///    onInvokeLoaded: () => PageViewModel.get(context).loadFirstData(context),
///    childBuilder: (value, context) { // 传入builder对象，挂载实例化后的widget，获取页面数据
///   return PageViewModel.get(context).pageModel.buildWithObserve((ctx, _state) {
///     return Container(
///       alignment: Alignment.center,
///       child: Center(
///         child: Text(
///           _state.dataFromNetwork,
///           style: TextStyle(
///             fontSize: 30,
///             color: Colors.blue,
///           ),
///         ),
///       ),
///     );
///   }, memo: (state) => [state.dataFromNetwork]);
/// },
/// onRetryClick: () {
///   PageViewModel.get(context).loadFirstData(context);
/// },
///);
///```
/// {@end-tool}
class LoadingPageWidget extends StatefulWidget {
  final OnRetryClick onRetryClick;
  final ContentBuilder childBuilder;
  final Widget failureWidget;
  final Widget emptyWidget;
  final String loadingVmName;
  final OnInvokeLoaded onInvokeLoaded;

  ///[childBuilder] widget builder 用于实例化显示内容的widget
  /// [onRetryClick]页面数据刷新的重试接口
  /// [failureWidget]页面数据刷新的失败后显示widget
  /// [emptyWidget]页面数据为空时显示widget
  /// [loadingVmName]使用的ViewModel标签，在多页面嵌套的情况，一个页面下widget tree，可能存在多个 LoadingPageWidget，我们需要指明loadingVmName用来表明具体刷新哪个loadingVmName的状态
  /// [onInvokeLoaded]LoadingPageWidget 初始化调用（内部维护了state，在initState中回调）
  const LoadingPageWidget({
    Key key,
    @required this.childBuilder,
    this.onRetryClick,
    this.failureWidget,
    this.emptyWidget,
    this.loadingVmName,
    this.onInvokeLoaded,
  }) : super(key: key);

  @override
  _LoadingPageWidgetState createState() => new _LoadingPageWidgetState();
}

class _LoadingPageWidgetState extends State<LoadingPageWidget>
    with LoadingControllerMixin, AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    if (widget.onInvokeLoaded != null) widget.onInvokeLoaded();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FacPageViewModel.get(context, instance: widget.loadingVmName).pageLiveData.buildWithObserve((ctx, _state) {

      return _buildStageChild(_state, context);
    });
  }

  Widget _buildStageChild(_PageModel value, BuildContext context) {
    if (value == null) {
      return _getStagedPageView(_FacPageState.state_empty);
    }
    switch (value.pageState) {
      case _FacPageState.state_loading:
      case _FacPageState.state_empty:
      case _FacPageState.state_failure:
        return _getStagedPageView(
          value.pageState,
          retryAction: widget.onRetryClick,
          emptyWidget: widget.emptyWidget,
          failureWidget: widget.failureWidget,
        );
      case _FacPageState.state_success:
        return _createPageChild(value, context);
    }
    return _getStagedPageView(_FacPageState.state_empty);
  }

  Widget _createPageChild(_PageModel viewModel, BuildContext context) => widget.childBuilder(viewModel, context);

  @override
  bool get wantKeepAlive => true;
}

class _PageModel {
  _FacPageState pageState = _FacPageState.state_loading;
}

/// PageViewModel用来管理状态，管理页面的切换状态 [pageState]
class FacPageViewModel extends ViewModel {
  static FacPageViewModel get(BuildContext context, {String instance}) {
    return ViewModel.of<FacPageViewModel>(
      context,
      builder: () => FacPageViewModel(),
      instance: instance,
    );
  }

  LiveState<_PageModel> _pageLiveData = LiveState<_PageModel>(_PageModel());

  LiveState<_PageModel> get pageLiveData => _pageLiveData;

  void showLoadingWidget() {
    _setPageState(_FacPageState.state_loading);
  }

  void showSuccessWidget() {
    _setPageState(_FacPageState.state_success);
  }

  void showFailWidget() {
    _setPageState(_FacPageState.state_failure);
  }

  void showEmptyWidget() {
    _setPageState(_FacPageState.state_empty);
  }

  void _setPageState(_FacPageState newState) {
    _pageLiveData.setState((value, _) {
      var oldState = value.pageState;
      if (oldState == _FacPageState.state_success && newState == _FacPageState.state_loading) {
        // 已经有内容。不进行任何通知静默刷新
        return;
      }
      if (newState != null && oldState != newState) {
        //状态相同时不同步UI
        value.pageState = newState;
      }
    });
  }
}

enum _FacPageState {
  state_loading,
  state_empty,
  state_failure,
  state_success,
}

/// MixinBasePage 展示StagedPageView的组件需要 with  LoadingControllerMixin
mixin LoadingControllerMixin {
  Widget _getStagedPageView(
    _FacPageState loadingStatus, {
    Function retryAction,
    Widget failureWidget,
    Widget emptyWidget,
  }) {
    Widget _contentWidget;
    switch (loadingStatus) {
      case _FacPageState.state_loading: // loading
        _contentWidget = StagedPageView(
          loadMode: LoadMode.loading,
        );
        break;
      case _FacPageState.state_empty: //empty
        _contentWidget = StagedPageView(
          loadMode: LoadMode.empty,
          emptyWidget: emptyWidget,
          callback: () {
            if (retryAction != null) {
              retryAction();
            }
          },
        );
        break;
      case _FacPageState.state_failure: //fail or error
        _contentWidget = StagedPageView(
          loadMode: LoadMode.failure,
          failureWidget: failureWidget,
          callback: () {
            if (retryAction != null) {
              retryAction();
            }
          },
        );
        break;

      case _FacPageState.state_success: // success
        return StagedPageView(
          loadMode: LoadMode.done,
        );
      default:
        return StagedPageView(
          loadMode: LoadMode.done,
        );
    }
    return _contentWidget;
  }
}

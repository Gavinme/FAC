import 'dart:async';

import 'package:example/widgets/staged_page_view.dart';
import 'package:flutter/material.dart';
import 'package:pikachu_fac/pikachu_fac.dart';

import 'loading_dialog.dart';

typedef OnRetryClick();
typedef OnInvokeLoaded();
typedef Widget ContentBuilder(PageModel model, BuildContext context);

///对外接口 [PkcPageViewModel]
class LoadingPageWidget extends StatefulWidget {
  final OnRetryClick onRetryClick;
  final ContentBuilder childBuilder;
  final Widget failureWidget;
  final Widget emptyWidget;
  final String loadingVmName;
  final OnInvokeLoaded onInvokeLoaded;

  const LoadingPageWidget({
    Key key,
    @required this.childBuilder,
    this.onRetryClick,
    this.failureWidget,
    this.loadingVmName,
    this.emptyWidget,
    this.onInvokeLoaded,
  }) : super(key: key);

  @override
  LoadingPageWidgetState createState() => new LoadingPageWidgetState();
}

class LoadingPageWidgetState extends State<LoadingPageWidget>
    with MixinLoadingController, AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    if (widget.onInvokeLoaded != null) widget.onInvokeLoaded();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ViewModel.of<PkcPageViewModel>(
      context,
      builder: () => PkcPageViewModel(),
      instance: widget.loadingVmName,
    ).pageLiveData.buildWithObserve(
      (ctx, _state) {
        return _buildStageChild(_state, context);
      },
    );
  }

  Widget _buildStageChild(PageModel value, BuildContext context) {
    if (value == null) {
      return _getStagedPageView(PkcPageState.state_empty);
    }
    switch (value.pageState) {
      case PkcPageState.state_loading:
      case PkcPageState.state_empty:
      case PkcPageState.state_failure:
        value._loadingDialog?.cancel();
        return _getStagedPageView(
          value.pageState,
          retryAction: widget.onRetryClick,
          emptyWidget: widget.emptyWidget,
          failureWidget: widget.failureWidget,
        );
      case PkcPageState.state_success:
        value._loadingDialog?.cancel();
        return _createPageChild(value, context);

      case PkcPageState.state_loading_dialog:
        if (value._loadingDialog != null) {
          if (value._loadingDialog.showing) {
            return _createPageChild(value, context);
          } else {
            Future<void>.delayed(
              Duration(milliseconds: 0),
              () => value._loadingDialog?.show(context),
            );
            return _createPageChild(value, context);
          }
        }
        value._loadingDialog ??= LoadingDialog();
        Future<void>.delayed(
          Duration(milliseconds: 0),
          () => value._loadingDialog?.show(context),
        );
        return _createPageChild(value, context);

      case PkcPageState.state_dismiss_dialog:
        value._loadingDialog?.cancel();
        return _createPageChild(value, context);
    }
    return _getStagedPageView(PkcPageState.state_empty);
  }

  Widget _createPageChild(PageModel viewModel, BuildContext context) => widget.childBuilder(viewModel, context);

  @override
  bool get wantKeepAlive => true;
}

class PageModel {
  PkcPageState pageState = PkcPageState.state_loading;
  LoadingDialog _loadingDialog;
}

/// PageViewModel用来管理状态，管理页面的切换状态 [pageState]
class PkcPageViewModel extends ViewModel {
  static PkcPageViewModel get(BuildContext context, {String instance}) {
    return ViewModel.of<PkcPageViewModel>(
      context,
      builder: () => PkcPageViewModel(),
      instance: instance,
    );
  }

  LiveState<PageModel> pageLiveData = LiveState<PageModel>(PageModel());

  void setPageState(PkcPageState newState) {
    pageLiveData.setState((value, _) {
      var oldState = value.pageState;
      if (oldState == PkcPageState.state_success && newState == PkcPageState.state_loading) {
        // 已经有内容。不进行任何通知静默刷新
        return;
      }
      if (newState != null && oldState != newState) {
        value.pageState = newState;
      }
    });
  }
}

enum PkcPageState {
  state_loading,
  state_empty,
  state_failure,
  state_success,
  state_loading_dialog,
  state_dismiss_dialog,
}

/// MixinBasePage 需要展示lodingview的组件需要 with  MixinBasePage
mixin MixinLoadingController {
  Widget _getStagedPageView(
    PkcPageState loadingStatus, {
    Function retryAction,
    Widget failureWidget,
    Widget emptyWidget,
  }) {
    Widget _contentWidget;
    switch (loadingStatus) {
      case PkcPageState.state_loading: // loading
        _contentWidget = StagedPageView(
          loadMode: LoadMode.loading,
        );
        break;
      case PkcPageState.state_empty: //empty
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
      case PkcPageState.state_failure: //fail or error
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

      case PkcPageState.state_success: // success
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

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'loading_dialog.dart';

/// LoadingView
///
/// 参考 [LoadMode]
class StagedPageView extends StatelessWidget {
  final Widget failureWidget;
  final Widget emptyWidget;

  /// 展示类型
  final LoadMode loadMode;

  /// 按钮点击事件
  final VoidCallback callback;

  const StagedPageView({
    @required this.loadMode,
    this.callback,
    this.failureWidget,
    this.emptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    switch (loadMode) {
      case LoadMode.done:
        return _DoneState();
      case LoadMode.loading:
        return _LoadingState();
      case LoadMode.failure:
        return _FailureState(
          failureWidget: failureWidget,
          retryCallback: callback,
        );
      case LoadMode.empty:
        return _EmptyState(
          emptyWidget: emptyWidget,
        );
    }
    return _DoneState();
  }
}

/// Loading状态
class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CommonLoadingWidget();
  }
}

/// 加载失败状态
class _FailureState extends StatelessWidget {
  final Widget failureWidget;

  /// 按钮点击事件
  final VoidCallback retryCallback;

  const _FailureState({
    @required this.failureWidget,
    this.retryCallback,
  });

  @override
  Widget build(BuildContext context) {
    // TODO 获取bruno 默认的 失败图
    return GestureDetector(onTap: retryCallback, child: failureWidget ?? _DefaultFailWidget());
  }
}

///_DefaultFailWidget
class _DefaultFailWidget extends StatelessWidget {
  const _DefaultFailWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('_DefaultFailWidget'),
      ),
    );
  }
}

///_DefaultFailWidget
class _DefaultEmptyFailWidget extends StatelessWidget {
  const _DefaultEmptyFailWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('_DefaultEmptyFailWidget'),
      ),
    );
  }
}

/// 空状态
class _EmptyState extends StatelessWidget {
  final Widget emptyWidget;

  const _EmptyState({
    @required this.emptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    // TODO 默认 bruno
    return emptyWidget ?? _DefaultEmptyFailWidget();
  }
}

class _DoneState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container();
  }
}

enum LoadMode {
  ///  加载完成： 不展示任何内容
  done,

  ///  加载中： 展示Loading，如果传递文案，下方展示一个文字
  loading,

  ///  加载失败： 失败状态，图标+文案+重试按钮。按钮点击事件回传
  failure,

  ///  空状态： 展示一个空图标，+文案+按钮。按钮点击事件回传
  empty,
}

library consumer;

import 'dart:async';

import 'package:flutter/material.dart';

typedef Observer = Widget Function<T>(BuildContext ctx, T state);

/// ## Consumer
///
/// > Consumer is like react.Consumer
///
/// Consumer is only one at project; it's single class.
/// Consumer have getState, and setState.
/// setState is trigger all stream listen, update state and call all Consumer widget update.
/// build is use _ConsumerWidget create a StatefulWidget, and subscribe consumer at _ConsumerWidget.
class LiveData<T> {
  T value;
  StreamController controller;
  Stream stream;

  LiveData(this.value) {
    controller = StreamController.broadcast();
    stream = controller.stream;
    stream.listen((data) {
      value = data;
    });
  }

  Widget observe(Widget Function(BuildContext ctx, T state) observer,
      {List<dynamic> Function(T s) memo}) {
    return _ConsumerWidget<T>(ctrl: this, memo: memo, builder: observer);
  }

  T getValue() {
    return value;
  }

  T setValue(Function(T state) fn) {
    fn(value);
    controller.add(value);
    return value;
  }
}

/// ## _ConsumerWidget
///
/// > _ConsumerWidget is like react.context.consumer style's state manage widget
///
/// builder[required]: use return widget
/// memo[required]: (state) => [], like react.useMemo, only array object is changed, widget can be update
/// _ConsumerWidget listen Store.stream at initState, and cancel listen at widget dispose.
class _ConsumerWidget<T> extends StatefulWidget {
  final LiveData<T> ctrl;
  final List<dynamic> Function(T state) memo;
  final Widget Function(BuildContext ctx, T state) builder;

  _ConsumerWidget(
      {@required this.ctrl,
      @required this.builder,
      @required this.memo,
      Key key})
      : super(key: key);

  @override
  _ConsumerWidgetState createState() =>
      _ConsumerWidgetState<T>(ctrl, memo, builder);
}

class _ConsumerWidgetState<T> extends State<_ConsumerWidget> {
  StreamSubscription _sub;
  List<dynamic> _lastMemo;
  final LiveData<T> _ctrl;
  final List<dynamic> Function(T state) _memo;
  final Widget Function(BuildContext ctx, T state) _builder;

  _ConsumerWidgetState(this._ctrl, this._memo, this._builder);

  @override
  void initState() {
    super.initState();
    if (_memo != null) {
      _lastMemo = [..._memo(_ctrl.value)];
    }

    _sub = _ctrl.stream.listen((data) {
      if (_memo == null) {
        setState(() {});
        return;
      }
      if (_lastMemo.length > 0) {
        bool isUpdate = false;
        List nowMemo = [..._memo(_ctrl.value)];
        for (var i = 0; i < _lastMemo.length; i++) {
          if (_lastMemo[i] != nowMemo[i]) {
            isUpdate = true;
            break;
          }
        }
        if (isUpdate == true) {
          if (mounted) {
            _lastMemo = nowMemo;

            setState(() {});
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _sub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return _builder(context, _ctrl.value);
  }
}

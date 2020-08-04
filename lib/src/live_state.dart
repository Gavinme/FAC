library consumer;

import 'dart:async';

import 'package:flutter/material.dart';

class StateOwner<T> {
  T state;
  bool _notify;

  StateOwner(this.state);
}

/// ## LiveData
///
/// > LiveData is like JetPack LiveData
///
/// LiveData have getState, and setState.
/// setState is trigger all stream listen, update state and call all LiveData widget update.
/// build is use _LiveDataWidget create a StatefulWidget, and subscribe LiveData at _LiveDataWidget.
class LiveState<T> {
  StreamController<StateOwner<T>> controller;
  StateOwner<T> owner;
  T _state;

  Map<Function(T state), StreamSubscription> _observers = Map();

  LiveState(T value) {
    this._state = value;
    owner = StateOwner<T>(_state);
    controller = StreamController.broadcast();
    controller.stream.listen((data) {
      this._state = data.state;
    });
  }

  Widget buildWithObserve(Widget Function(BuildContext ctx, T _state) observer, {List<dynamic> Function(T s) memo}) {
    return _LiveDataWidget<T>(ctrl: this, memo: memo, builder: observer);
  }

  void _observe(Function(T _state) observer) {
    dynamic subscription = controller.stream.listen((owner) => observer(owner.state));
    _observers.putIfAbsent(observer, () => subscription);
  }

  void _removeObserver(Function(T _state) observer) {
    if (_observers.containsKey(observer)) {
      dynamic subscription = _observers.remove(observer);
      (subscription as StreamSubscription).cancel();
    }
  }

  T getState() {
    return _state;
  }

  /// modify [_state] inner value
  /// if u want to cover the state use owner, owner.state=value;
  T setState(Function(T oldState, StateOwner<T> owner) fn, [bool notify = true]) {
    fn(_state, this.owner);
    this.owner._notify = notify;
    controller.add(this.owner);
    return _state;
  }
}

/// ## _LiveDataWidget
///
/// > _LiveDataWidget is like react.context.LiveData style's state manage widget
///
/// builder[required]: use return widget
/// memo[required]: (state) => [], like react.useMemo, only array object is changed, widget can be update
/// _LiveDataWidget listen Store.stream at initState, and cancel listen at widget dispose.
class _LiveDataWidget<T> extends StatefulWidget {
  final LiveState<T> ctrl;
  final List<dynamic> Function(T state) memo;
  final Widget Function(BuildContext ctx, T state) builder;

  _LiveDataWidget({@required this.ctrl, @required this.builder, @required this.memo, Key key}) : super(key: key);

  @override
  _LiveDataWidgetState createState() => _LiveDataWidgetState<T>(ctrl, memo, builder);
}

class _LiveDataWidgetState<T> extends State<_LiveDataWidget> {
  StreamSubscription _sub;
  List<dynamic> _lastMemo;
  final LiveState<T> _ctrl;
  final List<dynamic> Function(T state) _memo;
  final Widget Function(BuildContext ctx, T state) _builder;

  _LiveDataWidgetState(this._ctrl, this._memo, this._builder);

  @override
  void initState() {
    super.initState();
    if (_memo != null) {
      _lastMemo = [..._memo(_ctrl._state)];
    }

    _sub = _ctrl.controller.stream.listen((data) {
      if (_memo == null) {
        if (data._notify) {
          setState(() {});
        }
        return;
      }

      if (_lastMemo.length > 0) {
        bool isUpdate = false;
        List nowMemo = [..._memo(_ctrl._state)];
        for (var i = 0; i < _lastMemo.length; i++) {
          if (_lastMemo[i] != nowMemo[i]) {
            isUpdate = true;
            break;
          }
        }
        if (isUpdate == true) {
          if (mounted) {
            _lastMemo = nowMemo;
            if (data._notify) {
              setState(() {});
            }
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
    Widget widget = _builder(context, _ctrl._state);
    debugPrint('刷新... widget:(${widget.runtimeType}),liveState:(${_ctrl._state.runtimeType})');
    return widget;
  }
}

///合并数据源
class MediatorLiveState<T> extends LiveState<T> {
  MediatorLiveState(value) : super(value);
  Map<LiveState, dynamic> sources = Map();

  void addSource<S>(LiveState<S> source, Function(S state) observer) {
    source._observe(observer); //source 数据源变更同步observer
    sources.putIfAbsent(source, () => observer);
  }

  void removeSource<S>(LiveState<S> source) {
    if (sources.containsKey(source)) {
      dynamic observer = sources.remove(source);
      source._removeObserver(observer);
    }
  }
}

class Transformations {
//  static LiveState<Y> map <X, Y>(LiveState<X> source,
//                                 Function func) {
//    final MediatorLiveState<Y> result = MediatorLiveState();
//    result.addSource(source, (){
//      func();
//    })
//    return result;
//  }
}

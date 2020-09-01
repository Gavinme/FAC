import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pikachu_fac/pikachu_fac.dart';

typedef _FacWidgetBuilder<S> = Widget Function(BuildContext context, S state);
typedef _OnDiffStateFn<T> = Widget Function<T>(T _old, T _new);
typedef _OnChangeStateFn<T> = Function(T _st, _StateOwner<T> _owner);

///state owner
///[state]该类用来包装State，如果想要整体修改state，而不是修改state中的某个值，请调用该对象
class _StateOwner<T> {
  T state;
  bool _shouldUpdateWidget;

  _StateOwner(this.state);
}

class FacObserveBuilder<T> extends _LiveStateWidget<T> {
  FacObserveBuilder({
    LiveState<T> liveState,
    _FacWidgetBuilder<T> builder,
    List<dynamic> Function(T state) memo,
  }) : super(liveState: liveState, builder: builder, memo: memo);
}

/// ## LiveState
///
/// > LiveState is like JetPack LiveData
///
/// LiveState have getState, and setState.
/// setState is trigger all stream listen, update state and call all LiveState widget update.
/// build is use _LiveStateWidget create a StatefulWidget, and subscribe LiveState at _LiveStateWidget.
class LiveState<T> {
  StreamController<_StateOwner<T>> _controller;
  _StateOwner<T> _owner;
  T _state;

  _OnDiffStateFn<T> _isSameState;
  Map<dynamic, StreamSubscription> _observers = {};

  LiveState(T value, [this._isSameState]) {
    _owner = _StateOwner<T>(value);
    _controller = StreamController.broadcast();
  }

  ///see [FacObserveBuilder]
  /// [observer] use return widget
  /// [memo] (state) => [], like react.useMemo, only array object is changed, widget can be update
  @Deprecated('use FacBuilder instead')
  Widget buildWithObserve(
    _FacWidgetBuilder<T> observer, {
    List<dynamic> Function(T s) memo,
  }) {
    return _LiveStateWidget<T>(
      liveState: this,
      memo: memo,
      builder: observer,
    );
  }

  void _observe({
    Function(T _state) observer,
    List<dynamic> Function(T s) memo,
  }) {
    _ObserverProxy<T> observerProxy =
        _ObserverProxy<T>(_owner, _controller, observer, memo);

    _observers.putIfAbsent(observer, () => observerProxy._subscription);
  }

  void _removeObserver(Function(T _state) observer) {
    if (_observers.containsKey(observer)) {
      dynamic subscription = _observers.remove(observer);
      (subscription as StreamSubscription).cancel();
    }
  }

  T get state => _owner.state;

  ///读取state
  ///如果想修改state而不通知UI刷新，请使用[setState] 如，
  /// FacPageViewModel.get(context, instance: instance).pageLiveData.setState((value, _) {
  ///     ...
  /// },
  ///false);
  ///不要直接通过state修改值
  @Deprecated('use state instead!')
  T getState() {
    return _owner.state;
  }

  ///单纯的修改state而不去更新UI
  ///常见于表单数据同步到store，数据会通过steam发送给观察者，但是不会调用state的刷新功能，
  ///避免个体字段的变动，引起被关联组件刷新
  T setStatePure(_OnChangeStateFn<T> fn) {
    return _setState(fn, false);
  }

  /// [_state] modify inner value
  /// [_owner] if u want to cover the state ,please use [_owner]; just like,owner.state=value;
  T setState(_OnChangeStateFn<T> fn) {
    return _setState(fn, true);
  }

  /// [shouldUpdateWidget] 数据变更是否通知UI刷新
  T _setState(_OnChangeStateFn<T> fn, [bool shouldUpdateWidget = true]) {
    var _oldState = _owner.state;
    fn(_owner.state, this._owner);
    this._owner._shouldUpdateWidget =
        shouldUpdateWidget && !_checkSameState(_oldState, _owner.state);
    _controller.add(this._owner);
    return _owner.state;
  }

  bool _checkSameState(T _old, T _new) {
    return (_isSameState != null) ? _isSameState(_old, _new) : false;
  }
}

class _ObserverProxy<T> {
  List<dynamic> _lastMemo;
  dynamic _subscription;
  Function(T _state) observer;
  StreamController<_StateOwner> controller;
  List<dynamic> Function(T s) _memo;
  _StateOwner<T> owner;

  _ObserverProxy(
    this.owner,
    this.controller,
    this.observer,
    this._memo,
  ) {
    if (_memo != null) {
      // ignore: sdk_version_ui_as_code
      _lastMemo = [..._memo(owner.state)];
    }
    _subscription = controller.stream.listen((owner) {
      if (_lastMemo == null) {
        observer(owner.state);
        return;
      }

      if (_lastMemo.length > 0) {
        bool isUpdate = false;
        // ignore: sdk_version_ui_as_code
        List nowMemo = [..._memo(owner.state)];
        for (var i = 0; i < _lastMemo.length; i++) {
          if (_lastMemo[i] != nowMemo[i]) {
            isUpdate = true;
            break;
          }
        }
        if (isUpdate == true) {
          _lastMemo = nowMemo;
          observer(owner.state);
        }
      }
    });
  }
}

/// ## _LiveStateWidget
///
/// > _LiveStateWidget is like react.context.LiveState style's state manage widget
///
/// [builder] use return widget
/// [memo] (state) => [], like react.useMemo, only array object is changed, widget can be update
/// _LiveStateWidget listen Store.stream at initState, and cancel listen at widget dispose.
class _LiveStateWidget<T> extends StatefulWidget {
  final LiveState<T> liveState;
  final List<dynamic> Function(T state) memo;
  final _FacWidgetBuilder<T> builder;

  _LiveStateWidget(
      {@required this.liveState,
      @required this.builder,
      @required this.memo,
      Key key})
      : super(key: key);

  @override
  _LiveStateWidgetState createState() =>
      _LiveStateWidgetState<T>(liveState, memo, builder);
}

class _LiveStateWidgetState<T> extends State<_LiveStateWidget> {
  StreamSubscription _sub;
  List<dynamic> _lastMemo;
  final LiveState<T> _liveState;
  final List<dynamic> Function(T state) _memo;
  final _FacWidgetBuilder<T> _builder;

  _LiveStateWidgetState(this._liveState, this._memo, this._builder);

  @override
  void initState() {
    super.initState();

    if (_memo != null) {
      // ignore: sdk_version_ui_as_code
      _lastMemo = [...?_memo(_liveState.state)];
      print('_lastMemo:$_lastMemo');
    }

    _sub = _liveState._controller.stream.listen((data) {
      //不传memo列表或memo函数为空时
      if (_memo == null || _lastMemo == null || _lastMemo.length == 0) {
        if (data._shouldUpdateWidget) {
          setState(() {});
        }
        return;
      }

      if (_lastMemo.length > 0) {
        bool isUpdate = false;
        // ignore: sdk_version_ui_as_code
        List nowMemo = [..._memo(_liveState.state)];
        for (var i = 0; i < _lastMemo.length; i++) {
          if (_lastMemo[i] != nowMemo[i]) {
            isUpdate = true;
            break;
          }
        }
        if (isUpdate == true) {
          if (mounted) {
            _lastMemo = nowMemo;
            if (data._shouldUpdateWidget) {
              setState(() {});
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = _builder(context, _liveState.state);
    debugPrint(
        '刷新... widget:(${widget.runtimeType}),liveState:(${_liveState.state.runtimeType})');
    return widget;
  }
}

///合并数据源
class MediatorLiveState<T> extends LiveState<T> {
  Map<LiveState, dynamic> _sources = Map();

  MediatorLiveState(value) : super(value);

  MediatorLiveState.fromLiveState(LiveState<T> liveState)
      : super(liveState.state);

  void addSource<S>(
    LiveState<S> source,
    Function(S state) observer, {
    List<dynamic> Function(S s) memo,
  }) {
    source._observe(observer: observer, memo: memo); //source 数据源变更同步observer
    _sources.putIfAbsent(source, () => observer);
  }

  void removeSource<S>(LiveState<S> source) {
    if (_sources.containsKey(source)) {
      dynamic observer = _sources.remove(source);
      source._removeObserver(observer);
    }
  }

  ///[ViewModel]需要主动调用，并释放资源
  void dispose() {
    _sources?.forEach((k, v) => this.removeSource(k));
  }
}

///转换数据源
class Transformations {
  static LiveState<Y> map<X, Y>(
    LiveState<X> sourceX,
    LiveState<Y> sourceY,
    Function(X state) observer, {
    List<dynamic> Function(X s) memo,
  }) {
    MediatorLiveState<Y> mediatorLiveState =
        MediatorLiveState.fromLiveState(sourceY);
    mediatorLiveState.addSource(sourceX, observer, memo: memo);
    return mediatorLiveState;
  }
}

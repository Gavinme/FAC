import 'package:example/widgets/loading_page.dart';
import 'package:flutter/material.dart';

import '../page_view_model.dart';

/// 创建时间：2020/8/4
/// 作者：Gavin
/// 描述：
///FirstTabWidget
class FirstTabWidget extends StatelessWidget {
  const FirstTabWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("LoadingPage"),
      ),
      body: _buildFirstContentWidget(context),
    );
  }
}

LoadingPageWidget _buildFirstContentWidget(BuildContext context) {
  return LoadingPageWidget(
    onInvokeLoaded: () => PageViewModel.get(context).loadFirstData(context),
    failureWidget: Container(
      alignment: Alignment.center,
      child: Center(
        child: Text(
          'custom fail hint,click retry',
          style: TextStyle(
            fontSize: 30,
            color: Colors.red,
          ),
        ),
      ),
    ),
    emptyWidget: Container(
      alignment: Alignment.center,
      child: Center(
        child: Text(
          "Custom empty hint",
          style: TextStyle(
            fontSize: 30,
            color: Colors.blue,
          ),
        ),
      ),
    ),
    childBuilder: (value, context) {
      return PageViewModel.get(context).pageModel.buildWithObserve((ctx, _state) {
        return Container(
          alignment: Alignment.center,
          child: Center(
            child: Text(
              _state.dataFromNetwork,
              style: TextStyle(
                fontSize: 30,
                color: Colors.blue,
              ),
            ),
          ),
        );
      }, memo: (state) => [state.dataFromNetwork]);
    },
    onRetryClick: () {
      PageViewModel.get(context).loadFirstData(context);
    },
  );
}

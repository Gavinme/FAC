import 'package:flutter/material.dart';

import '../page_view_model.dart';

/// 创建时间：2020/7/5
/// 作者：Gavin
/// 描述：

class SecondTabWidget extends StatelessWidget {
  const SecondTabWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: PageViewModel.get(context).pageModel.buildWithObserve(
          (ctx, _state) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_state.appBarTitle),
            );
          },
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          PageViewModel.get(context).pageModel.buildWithObserve((ctx, _state) {
            //建立数据和UI的绑定关系
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Row(
                children: <Widget>[
                  Text(
                    '刷新优化，只有count变化才刷新: ${_state.count}',
                  ),
                ],
              ),
            );
          }, memo: (value) => [value.count]),
          const Divider(),
          const Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('修改appbar'),
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: PageViewModel.get(context).pageModel.buildWithObserve(
                (ctx, _state) {
                  return TextFormField(
                    onChanged: (_state) {
                      PageViewModel.get(context).pageModel.setState((v, l) {
                        l.state.appBarTitle = _state;
                      });
                    },
                  );
                },
              )),
        ],
      ),
    );
  }
}

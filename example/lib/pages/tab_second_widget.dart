import 'package:example/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pikachu_fac/pikachu_fac.dart';

import '../page_view_model.dart';
import 'list_page.dart';

/// 创建时间：2020/7/5
/// 作者：Gavin
/// 描述：

class SecondTabWidget extends StatelessWidget {
  const SecondTabWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: FacObserveBuilder<PageModel>(
              memo: (_state) => [],
              liveState: PageViewModel.get(context).pageModel,
              builder: (ctx,  _state) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:TitleWidget(_state.appBarTitle) ,
                );
              })),
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
          PageViewModel.get(context)
              .mediatorLiveState
              .buildWithObserve((ctx, _state) {
            //建立数据和UI的绑定关系
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Row(
                children: <Widget>[
                  Text(
                    '数据源监听A*2->B: $_state',
                  ),
                ],
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PageViewModel.get(context).pageModel.buildWithObserve(
                (ctx, st) => new Row(
                      children: <Widget>[
                        Text('开关:'),
                        Checkbox(
                          value: st.check,
                          onChanged: (value) {
                            PageViewModel.get(context).onCheckedChanged(value);
                          },
                        ),
                        Text(' 开关状态:'),
                        Text('${st.check}'),
                      ],
                    ),
                memo: (st) => [st.check]),
          ),
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
                    onChanged: (_value) {
                      PageViewModel.get(context).onInputValueChanged(_value);
                    },
                  );
                },
              )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                RaisedButton(
                    child: const Text('跳转新页面(App数据)'),
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (ctx) => SecondTabWidget()))),
                Center(child: Text('区别于bloC，新开页面会立即同步数据')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              child: const Text('显示loading'),
              onPressed: () {
                LoadingDialog.get().show(context);
                Future.delayed(Duration(milliseconds: 2000),
                    () => LoadingDialog.get().cancel());
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              child: const Text('列表页演示'),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => ViewModelStoreProxyWidget(
                          child: ListPage(),
                        )));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              child: const Text('详情页演示'),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => SecondTabWidget()));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              child: const Text('表单页演示'),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => SecondTabWidget()));
              },
            ),
          )
        ],
      ),
    );
  }
}

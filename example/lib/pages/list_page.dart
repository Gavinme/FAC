import 'package:example/pages/tab_third_widget.dart';

/// 创建时间：2020/8/20
/// 作者：Gavin
/// 描述：
import 'package:example/widgets/loading_page.dart';
import 'package:flutter/material.dart';

import '../page_third_data.dart';
import '../page_view_model.dart';

class TitleWidget extends StatefulWidget {
  final String appBarTitle;

  TitleWidget(this.appBarTitle);

  @override
  TitleWidgetState createState() => new TitleWidgetState();
}

class TitleWidgetState extends State<TitleWidget> {
  @override
  void initState() {
    debugPrint('${runtimeType.toString()} initState');
    super.initState();
  }

  @override
  void didChangeDependencies() {
    debugPrint('${runtimeType.toString()} didChangeDependencies');
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('${runtimeType.toString()} build');
    return new Text(widget.appBarTitle ?? '');
  }

  @override
  void deactivate() {
    debugPrint('${runtimeType.toString()} deactivate');
    super.deactivate();
  }

  @override
  void didUpdateWidget(TitleWidget oldWidget) {
    debugPrint('${runtimeType.toString()} didUpdateWidget');
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    debugPrint('${runtimeType.toString()} dispose');
    super.dispose();
  }
}

///ListPage
class ListPage extends StatelessWidget {
  const ListPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TitleWidget('ListPage'),
      ),
      body: LoadingPageWidget(
        onInvokeLoaded: () => PageViewModel.get(context).loadListPage(context),
        childBuilder: (_, context) => SafeArea(
          top: false,
          bottom: false,
          child: _createScrollBuilder(),
        ),
      ),
    );
  }
}

Builder _createScrollBuilder() {
  return Builder(
    builder: (BuildContext context) {
      return CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            sliver: PageViewModel.get(context)
                .pageList
                .buildWithObserve((_, pages) => SliverFixedExtentList(
                      itemExtent: CardDataItem.height,
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          final CardData data = pages[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                            ),
                            child: CardDataItem(
                              page: Page(label: 'APP'),
                              data: data,
                            ),
                          );
                        },
                        childCount: pages.length,
                      ),
                    )),
          ),
        ],
      );
    },
  );
}

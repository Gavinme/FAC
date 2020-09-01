import 'package:example/pages/tab_first_widget.dart';
import 'package:example/pages/tab_second_widget.dart';
import 'package:example/pages/tab_third_widget.dart';
import 'package:flutter/material.dart';

import '../page_view_model.dart';

class HomePageWidget extends StatefulWidget {
  @override
  HomePageWidgetState createState() => new HomePageWidgetState();
}

class HomePageWidgetState extends State<HomePageWidget> {
  PageController _controller;

  Widget _buildTabWidget(BuildContext context) {
    const _pages = [
      const FirstTabWidget(),
      const SecondTabWidget(),
      const ThirdTabWidget()
    ];
    return PageView.builder(
        physics: NeverScrollableScrollPhysics(), //viewPage禁止左右滑动
        controller: _controller,
        itemCount: _pages.length,
        itemBuilder: (context, index) => _pages[index]);
  }

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
//    PageViewModel.get(context).testMedia();
    PageViewModel.get(context).testTransformations();
    debugPrint('${runtimeType.toString()} initState');
    super.initState();
  }

  @override
  void deactivate() {
    debugPrint('${runtimeType.toString()} deactivate');
    super.deactivate();
  }

  @override
  void didUpdateWidget(HomePageWidget oldWidget) {
    debugPrint('${runtimeType.toString()} didUpdateWidget');
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    debugPrint('${runtimeType.toString()} dispose');
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('${runtimeType.toString()} build');
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          tooltip: 'Increment',
          child: Icon(Icons.add),
          onPressed: () {
            switch (
                PageViewModel.get(context).pageModel.state.currentTabIndex) {
              case 0:
                PageViewModel.get(context).loadFirstData(context);
                break;
              case 1:
                PageViewModel.get(context).onCountClick(context);

                break;
              case 2:
                PageViewModel.get(context).loadThirdData(context,
                    instance: (PageViewModel.get(context).getTabIndex()));
                break;
            }
          },
        ),
        body: _buildTabWidget(
          context,
        ),
        bottomNavigationBar: PageViewModel.get(context)
            .pageModel
            .buildWithObserve((ctx, st) => BottomNavigationBar(
                  currentIndex: (st.currentTabIndex),
                  onTap: (index) {
                    _controller.jumpToPage(index);
                    PageViewModel.get(context).pageModel.setState((value, _) {
                      _.state.currentTabIndex = index;
                      print('change tab index!');
                    });
                  },
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                        title: Text('首页'), icon: Icon(Icons.home)),
                    BottomNavigationBarItem(
                        title: Text('书籍'), icon: Icon(Icons.book)),
                    BottomNavigationBarItem(
                        title: Text('我的'), icon: Icon(Icons.perm_identity)),
                  ],
                )));
  }
}

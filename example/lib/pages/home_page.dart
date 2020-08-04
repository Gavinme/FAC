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
    const _pages = [const FirstTabWidget(), const SecondTabWidget(), const ThirdTabWidget()];
    return PageView.builder(
        physics: NeverScrollableScrollPhysics(), //viewPage禁止左右滑动
        controller: _controller,
        itemCount: _pages.length,
        itemBuilder: (context, index) => _pages[index]);
  }

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          tooltip: 'Increment',
          child: Icon(Icons.add),
          onPressed: () {
            switch (PageViewModel.get(context).pageModel.getState().currentTabIndex) {
              case 0:
                PageViewModel.get(context).loadFirstData(context);
                break;
              case 1:
                PageViewModel.get(context).onCountClick(context);

                break;
              case 2:
                PageViewModel.get(context).loadThirdData(context,
                    instance: (PageViewModel.get(context).thirdPageModel.getState().index == 0 ? 'HOME' : 'APPAREL'));
                break;
            }
          },
        ),
        body: _buildTabWidget(
          context,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: (PageViewModel.get(context).pageModel.getState().currentTabIndex),
          onTap: (index) {
            _controller.jumpToPage(index);
            PageViewModel.get(context).pageModel.setState((value, _) {
              _.state.currentTabIndex = index;
            });
          },
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(title: Text('首页'), icon: Icon(Icons.home)),
            BottomNavigationBarItem(title: Text('书籍'), icon: Icon(Icons.book)),
            BottomNavigationBarItem(title: Text('我的'), icon: Icon(Icons.perm_identity)),
          ],
        ));
  }
}

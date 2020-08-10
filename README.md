# FAC（Flutter Architecture Components）

`FAC` Flutter 架构组件（Flutter Architecture Components） 致力于解决Flutter跨组件刷新和集中化状态管理、关注点分离、构建高性能Flutter页面；

源码请查看：[Github](https://github.com/Gavinme/flutter-architecture-component-JetPack)

### Feature

与Provider相比：

- `FAC`提供了强大了解耦装置`ViewModel`；
- 更为简洁的状态关联方式；
- 以页面或APP纬度的集中化状态管理`ViewModelStore`；
- 更高效的刷新机制（支持`LiveState`对状态隔离，`memo`过滤参数列表）
- 在initState中可以触发状态更新，比如加载数据，初始化页面数据等


### FAC架构组件模型

![image.png](https://i.loli.net/2020/08/04/eP3pW5xHOZ9kctY.png)

没错，FAC看起来与AAC（[Android Architecture Components](https://developer.android.google.cn/jetpack/docs/guide)）框架如出一辙，我们构建了带有生命周期监听的可观察数据对象LiveState，用于实现状态和UI控制器绑定；并实现`ViewModelStoreProxyWidget`用来存储和卸载ViewModel对象——当然在业务开发中，我们并不需要关注它的存在，会在架构层合适的位置进行注入；

这一切，对熟悉Android原生AAC组件的开发者来说，是一个福音；因为相对大而笨重的Provider，复杂的Redux框架来说，对FAC的学习是零成本！



### 使用场景

* 组件状态共享，组件间状态可被观察
* 跨组件通信/刷新
* 任意代码位置获取目标组件状态并刷新
* 某个组件需要改变全局状态
* 构建大型复杂业务及多页面嵌套场景

### 安装 FAC
修改 `pubspec.yaml`

```
dependencies:
  pikach_fac: ^1.0.3
```

### 使用
三步搞定企业级复杂业务场景、代码分层和状态管理：
- 1.定义ViewModel和Model数据类型

```
class PageViewModel extends ViewModel {
  LiveState<PageModel> pageModel = LiveState<PageModel>(PageModel());

  ///定义静态方法，便于任意位置获取PageViewModel的实例（可选）
  static PageViewModel get(BuildContext context) {
    return ViewModel.of<PageViewModel>(
      context,
      builder: () => PageViewModel(),
    );
  }
  ///定义业务的实现
  void onCountClick(BuildContext context) {
    PageViewModel.get(context).pageModel.setState((value, _) {
      _.state.count++;
    });
  }

}

```

- 2.定义LiveState
```
LiveState<PageModel> pageModel = LiveState<PageModel>(PageModel());
```
- 3.UI和状态绑定

```
  ///建立数据和UI的绑定关系
  PageViewModel.get(context).pageModel.buildWithObserve((ctx, _state) {

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
  }, memo: (value) => [value.count])
```

详细代码请查阅[Github](https://github.com/Gavinme/flutter-architecture-component-JetPack)

### 数据流

![image.png](https://i.loli.net/2020/08/04/BfvKnhCu3rcsbl2.png)


### 架构设计背景
架构设计的初衷，是为了解决Flutter在复杂的嵌套页面场景下，能够有效的管理页面的状态和刷新效率；对于简单的业务场景，同样有友好的代码分层和状态管理能力！

以下是业务中采用FAC开发的Flutter页面：

![image.png](https://i.loli.net/2020/08/05/quZUKAQopXvz1IG.png)



# 组件

### 1. LiveState组件

`LiveState`：可被观察的数据组件；称之为Live的原理，是因为它可以感知Widget组件的生命周期！

`LiveState` 可用于构建可被观察的数据对象，即构建model；在数据发生变更时，并且在生命周期合法的情况，能够及时通知到观察者；用于分发或转发数据对象（MediatorLiveState可以用作转发或合并数据源）；

`LiveState`可以单独使用，去构建跨组件刷新模型；
但是我们更推荐将其放在 ViewModel 组件中，这样可以将model对象转化成 ViewModel ，从而构建 UI 和 Model 分离的代码结构！

```
//在ViewModel中实例化LiveState对象
LiveState<ReportRequestModel> _reportRequest;

LiveState<ReportRequestModel> get reportRequest =>
  _reportRequest ??= LiveState<ReportRequestModel>(ReportRequestModel());

```

##### 其他接口
LiveState提供其它相关接口，用于响应式编程开发；

- `StateOwner` 用于提供state的整体变更
```
class StateOwner<T> {
  T state;
} 
```
- `MediatorLiveState` 用于合并多个LiveState数据源，更利于构建响应式应用
![image.png](https://i.loli.net/2020/08/04/veZoHs4kU6TA879.png)
- `Transformations` 用于LiveState数据源变化，由于dart不支持反射，可能并没有那么好用，建议直接用 `MediatorLiveState` 替代

### 2. ViewModel组件
`ViewModel`：分离数据和 UI，专注于逻辑处理，构建数据和UI的双向绑定；

另外，该类中提供appContext用于navigation等与element无关的调用，该context来自于VMS！

##### 1.生命周期安全 
`ViewModel` 的声明周期与当前页面周期是一致的，不需要担心内存泄漏或关注回收的工作；

##### 2.数据和UI解耦

直接使用 Provider，需要手动构建 ViewModel 构建数据和 UI 的解耦模型；而 ViewModel 组件为解决该问题应运而生！
 ViewModel 可以用来管理UI所需的相关数据，承担UI和Model之间的交互和处理业务逻辑。
在页面的任何位置，我们可以通过`ViewModel.of<T>(context)`获取相应的 ViewModel 实例，从而建立UI和Model的`双向关联`！
ViewModel 可以胜任各种复杂的交互、业务逻辑、异步调用等；我们所有的修改都基于model，model 会自动关联注册的UI对象（Flutter Widget），从而构建一个单一数据源的模型;
因为组件的刷新是通过Model自动关联的（而不是调用 State 中的 `setState() `方法），我们更期望通过仅使用StatelessWidget去构建应用！

##### 3.构建跨组件通信接口
ViewModel用来提供自定义组件刷新接口
比如一个 AppBar需要提供title改变的接口，或 AppBar 的右侧Action中提供一个购物车数量指示。典型的跨组件刷新问题，可以通过 ViewModel 向往提供接口，开发者可以按需调用！

### 3. ViewModelStoreProxyWidget 组件

类似Redux中Store但是 ViewModelStoreProxyWidget 中共享的数据是当前页面相关的；开发者往往不需要关注它的存在，因为我们会通过框架在合适的位置注入。
##### _ViewModelStore 数据存储组件
类似Android中 lifecycle-viewmodel 组件包里的 ViewModelStore 组件，ViewModelStoreProxyWidget 作为页面顶级Widget，通过 InheritedWidget 共享页面的数据！当然，它的存储方式和原生端 VMS 如出一辙，采用`Map<Type, dynamic>()`对ViewModel进行存储；另外，我们为了适应复杂的大型应用场景，增加了`final _factoriesByName = Map<String, dynamic>();`的存储方式，可以存储多个同名的 `ViewModel`，使得单页面中的同组件类型接口问题得以解决!

### 设计原理
![image.png](https://i.loli.net/2020/08/04/as7iXFLq2leSzPE.png)

### 代理拦截与代理穿透
- 代理拦截

我们在任何位置可以轻松获取数据源并刷新UI的便利很大程度来源于代理拦截机制。如下，`ViewModel.of<CountViewModel>(context).model`

所谓的代理机制，原理很简单，我们会通过Provider在合适位置注册VMS进行节点拦截，因为inheritWidget会在最近位置通过泛型获取数据，从而达到拦截的目的。
收益：
- 防止外层页面和当前子页面数据混用
- 在任何位置可以获取数据并刷新UI


- 代理穿透

供代理拦截机制后，我们如何获取外层组件数据呢？
ViewModel提供了一种代理穿透的方式获取更外层数据。

代理拦截和代理穿透模式如下
![image.png](https://i.loli.net/2020/08/04/cPVC4UvnGu6hAQl.png)

![代理截断的场景.png](https://i.loli.net/2020/08/04/jYlUOQeid5LFbZ7.png)

代理穿透演示
![image.png](https://i.loli.net/2020/08/04/ORcorInq5WaZbes.png)

 共享Stroe

页面通过 instanceName 参数，可以在一个VMS下面共享多个同类型ViewModel；从而在一个页面下面，可以嵌套多个同类型组件，并调用不同组件的方法；



# 拓展

### 自定义组件接口
自定义组件如何对外提供组件刷新接口？

##### 直接使用Provider
Provider的方式是通过在上层节点上挂载Provider<T>通过ChangeNotifier构建的Model刷新 Provider 实例刷新Consumer<T>下的子组件。这个过程对于我而言，异常的漫长，且过于耦合；不能提供一个对外跨组件刷新的接口。

##### 使用FAC

有没有什么方式能通过，提供自定义组件的同时，提供组件的`对外刷新接口`，且这个组件刷新接口可以在代码的任何位置被调用？比如 AppBar 提供标题修改的接口，购物车提供商品数量变化的接口；

- LoadingPage实现   
LoadingPage是页面状态管理组件，有页面加载、错误、空数据、显示等状态；

由于使用FAC时，可以在页面任意位置获取ViewModel的实例，我们可以在开发自定义Widget LoadingPage的时候提供一个VM接口；外部可以使用该接口进行刷新：
```
PkcPageViewModel.get(context, instance: instance).pageLiveData.setState((value, _) {
        value.pageState = PkcPageState.state_loading;
      });
```
请查阅关于LoadingPage的组件实现[Github](https://github.com/Gavinme/flutter-architecture-component-JetPack)


- AppBar刷新和购物车接口
![image.png](https://i.loli.net/2020/08/04/MqPuFHZAjOKGBhc.png)
![image.png](https://i.loli.net/2020/08/04/FrkOvuytD7l5jmA.png)

# 参考


- [应用架构指南](https://developer.android.google.cn/jetpack/docs/guide)
- [LiveData beyond the ViewModel — Reactive patterns using Transformations and MediatorLiveData](https://medium.com/androiddevelopers/livedata-beyond-the-viewmodel-reactive-patterns-using-transformations-and-mediatorlivedata-fda520ba00b7)
- [Understanding LiveData made simple](https://medium.com/mobile-app-development-publication/understanding-live-data-made-simple-a820fcd7b4d0)

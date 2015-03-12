
**本攻略翻译整理改编自[raywenderlich](http://www.raywenderlich.com/86521/how-to-make-a-view-controller-transition-animation-like-in-the-ping-app)，与原文内容有一定区别。本攻略里使用Swift+Storyboard实现，我的下一篇文章会使用Objective-C+纯代码实现同样效果**
*****

#Cooool Animation！
![image](http://cdn4.raywenderlich.com/wp-content/uploads/2014/12/ping.gif)

随着iOS7的扁平话后，各种酷炫的动画越来越多，很多优秀的APP总会有令人深刻的动画效果，这些动画也是提升用户体验的一种手段。比如上面这款名为**Ping**的应用。

**Ping**一个令人印象深刻的地方就是它在主屏和菜单之间的圆形转场动画，就像你上面看到的那样。

每次我看到这些酷炫到没朋友的动画，我想我跟大家的想法一样：这些动画到底TMD怎么在iOS上实现的。。---等等，正常人不会去考虑这玩意？:(

###本攻略效果
![image](http://cdn4.raywenderlich.com/wp-content/uploads/2014/10/circle-interactive.gif)

**正如你看到的，本攻略的效果不但支持点击，重要的是还支持手势交互！**

在这篇攻略中，你将get到的新技能是：学会怎么用Swift+Storyboard实现很cooool的过度动画。在这段旅程中，你会了解**shape layer**， **masking**，**UIViewControllerAnimatedTransitioning**协议，**UIPercentDrivenInteractiveTransition**类等等。

本篇攻略前提是你有iOS开发的基础和大概了解Swift。如果你是一个想学iOS的真菜鸡无双，可以先去别的地方逛逛~。

#总体策略
在iOS中，我们非常习惯时候NavigationController来作为APP的导航，你八成已经看腻了系统自带的专场动画，Now，iOS7以后我们可以实现自定义的转场动画，并且当你转场的时候，仍然只需简单使用你早已烂熟的**pushNavigationCtroller:Animated:**方法！而你所要做的，就是实现NavigationControl的delegate并且实现用来执行动画的**UIViewControllerAnimatedTransitioning**协议。

这个协议总体上能让你：

* 设置动画的持续时间
* 建立一个包含两个view controller的container view
* 扩大你的脑洞，自由code你的转场动画

你可以使用高级封装的UIView动画或者更底层的CoreAnimation，本攻略中使用的是更自由的CoreAnimation。：）

#实现

接下来我们来深入研究怎么实现圆形转场。

我们来试着用语言来描述一下动画的过程：
* 右上角的button里会钻出来一个圆形，然后慢慢扩大，呈现里面的内容。
* 换句话说，这个圆形就像一个遮罩一样盖住了它底下的内容。

你可以使用**CALayer**里的**mask**来实现这个效果，它的alpha通道描述了layer哪些部分显示。

alpha为1的部分展示了这个layer里的内容，alpha为0的部分则隐藏了其内容。如下面这张示意图：
![image](http://cdn3.raywenderlich.com/wp-content/uploads/2014/10/mask-diagram.png)

我想你大概对**mask**有了了解，下一步就要决定要使用哪种类型的mask。由于我们的动画有一个圆形的mask，因此通常使用**CAShapeLayer**。要让圆形动起来，你只需要简单地增加circle mask的半径。

#开始动手

我们整理出了策略，是时候来码一些代码了！

选择*File\New\Project*建立一个Xcode的新工程，然后选择*iOS\Application\Single View Application*。

![image](http://cdn1.raywenderlich.com/wp-content/uploads/2014/10/step-1.png)

![image](http://cdn4.raywenderlich.com/wp-content/uploads/2014/10/step-2.png)

点开**Main.storyboard**。你会看见一个view controller，但是转场需要多个view controller来切换。

但是首先要做的是，你应该把view controller包裹在一个navigation controller中。通过Document Outline或者在canavas中选中view controller，然后选择*Editor\Embed In\Navigation Controller*。

接下来选中navigation controller，在右侧Attributes Inspector的Utilities控制板中取消**Shhows Navigation Bar**的勾选，因为我们的设计并没有navigationBar。

![image](http://cdn1.raywenderlich.com/wp-content/uploads/2014/10/Screenshot-2014-10-25-03.25.11-337x320.png)

然后是时候在storyboard中添加view controller了。为了一些强迫症患者，让我们以navigation controller为准水平排列他们仨。

![image](http://cdn3.raywenderlich.com/wp-content/uploads/2014/12/ViewControllers.png)

选择新的view controller，然后在右侧的Utilities控制板，选中Identity Inspector。把Class改为ViewController。

![image](http://cdn4.raywenderlich.com/wp-content/uploads/2014/10/Screenshot-2014-10-23-03.20.25-273x320.png)

下一步，为每个view controller在右上角添加一个button
## 3.0.15
- Fix the issue of sliding stuttering in the setLongPressCursorEnabled scenario

## 3.0.14
- Fix the issue where LineChart and BarChart cannot slide in the sliding component

## 3.0.13
- 修复HorizontalBarChart的limitLine不显示和文字较粗的问题
- 修复拖动图表后高亮线消失的问题
- 允许设置图表是否抗锯齿

## 3.0.12
- 修复 onChartTranslate 回调方法中调用model.getLowestVisibleX结果不对的问题。

## 3.0.12-rc.0
- 修改透明度不正确的问题
- 修复while循环卡住的问题
- 修改日志打印方法
- 优化二维矩阵变化方法mapPoints的执行速度

## 3.0.11
- 增加图表设置触摸测试类型接口：setHitTestMode

## 3.0.11-rc.0
- 修复PieChart只有一个数据时点击消失的问题
- 修复moveViewTo,centerViewTo,centerViewToY方法失效的问题

## 3.0.10
- 修复自定义的GridLine会超出图表的问题

## 3.0.9
- 修复特定情况下线形图数据圆点显示透明的问题

## 3.0.8
- 发布3.0.8正式版

## 3.0.8-rc.1
- 修复设置藏语后文字显示不全的问题
- 删除冗余代码，抽取代码到基础Component中：BarLineBaseChart和PieRadarBaseChart

## 3.0.8-rc.0
- 更换canvas的clearRect接口为reset接口，去掉checkValue方法，优化性能
- 修复YAxis 中的 mDrawBottomYLabelEntry 变量缺少set方法的问题
- 修复WaterFallChart的demo图有数据标签但没有柱状条的问题

## 3.0.7
- 修复长按游标setLongPressCursorEnabled功能，图表快速来回滑动也会出现游标的问题

## 3.0.7-rc.0
- 修复LineChart通过dataSet.setCircleColors方法设置多种颜色数据点失效的问题。此次修改可能导致部分低版本SDK API 12镜像设备数据点不显示，请更新版本镜像解决（对SDK API 11镜像设备无影响）。
- 修复LineChart线条设置多种颜色时不显示的问题
- 修复PieChart的EntryLabel为空心字的问题
- 导出WaterfallBuffer和WaterfallChartRenderer类用于自定义绘制

## 3.0.6
- 修复长按出游标功能setLongPressCursorEnabled场景下，点按图表会概率性不出游标的问题

## 3.0.5
- 修复BubbleChart,CandlestickChart,CombinedChart,HorizontalBarChart,ScatterChart图表响应单击事件较慢的问题
- 修复挂机上报localX undefined的问题
- 修复柱状图数据为0时会显示一条横线的问题

## 3.0.4
- 修复onNothingSelected重复调用的问题

## 3.0.4-rc.0
- 修复x轴坐标全是负数时，最右边的坐标不显示的问题

## 3.0.3
- 修复LineChart设置高亮线虚线（enableDashedHighlightLine）无效的问题

## 3.0.3-rc.5
- 优化瀑布图WaterfallChart的滑动耗时
- 优化设置虚线耗时
- 优化性能：1.去掉多余pathValueToPixel方法调用2.缓存文本值
- 修复barchart文本位置不对的问题

## 3.0.3-rc.4
- 修复markerView不显示的问题

## 3.0.3-rc.3
- 修复挂机上报ArkTools is not defined问题（默认关闭手动GC，可通过model.GCEnable = true开启手动GC）

## 3.0.3-rc.2
- 修复GridLine默认带透明度且不可修改的问题，可通过this.model?.getAxisLeft()?.setGridAlpha(0);设置不透明度

## 3.0.3-rc.1
- 增加惯性滑动功能
- 增加显示图标功能
- 修复x轴坐标显示颜色加深的问题
- 优化文本大小测量速度

## 3.0.3-rc.0
- 导出MyRect类，EventType类
- 修复设置一条虚线后所有线段都为虚线的问题
- 修复瀑布图高亮颜色显示的问题
- 优化LineChart游标响应速度

## 3.0.2
- 长按游标新增滑动响应能力
- 修复大数据上报的空指针异常问题
- 修复滑动图表时内存上涨且内存回收不及时的问题
- 修复设置一条虚线后所有线段都为虚线的问题

## 3.0.1
- 修复在aboutToAppear时设置moveViewToX方法失效的问题
- 修复x轴有较多labels时，并设置valueFormatter后卡顿的问题，允许设置自定义标签
- 修复长按时出现游标的问题
- 修复两端dataset中间有空隙时，移动手指出现高亮点闪动的问题
- 引入LogUtil类，规整日志打印

## 3.0.1-rc.4
- 支持设置x轴标签位置及偏移量
- 新增长按游标响应能力
- 修复抬起手指之后游标就消失的问题
- 修复渐变色填充颜色位置不对的问题

## 3.0.1-rc.3
- 修复双指缩放失效的问题
- 新增瀑布图设置和获取高亮点颜色方法
- 修复手指滑动到图表外，游标依然选中的问题

## 3.0.1-rc.2
- 修复LineChart和BarChart长按后无法滑动的问题

## 3.0.1-rc.1
- 修复图表滑动缩放问题
- 修复双指一起点击，出现的markerview位置不对的问题
- 修复x轴坐标旋转后显示不全的问题
- 修复List中的图表滑动掉帧的问题

## 3.0.1-rc.0
- 修复x轴文字倾斜后没有贴近轴线的问题
- 修复柱状图代表值为负值时，顶部圆角仍绘制在顶部的问题，支持图表 isInverted 场景，使能柱状图阴影展示时上下均绘制圆角

## 3.0.0
- 修复文字、offset、sliceSpace等数据的数值单位不正确问题
- 修复x轴标签位置不对的问题
- 修改Color类名称为ChartColor

## 3.0.0-rc.2
- 修改waterfallChart的标记颜色为外部传入
- 新增竖向柱状图设置顶部圆角的能力
- 修复setTouchEvent(false)关闭所有触摸交互不生效的问题
- 修复填充颜色基线错误的问题
- 瀑布图显示能力迁移
- 新增通过Y轴刻度范围将瀑布图绘制成多种颜色的能力
- 新增在瀑布图上高亮显示最高点和最低点,其余按照特定透明度显示的能力
- 修复图表滑动卡顿的问题
- 修改瀑布图可视区域变化时默认最高最低点高亮变成多个的问题
- 新增组合图添加瀑布图的能力
- 修改瀑布图高亮设置,将根据Y轴刻度范围绘制跟普通高亮设置区分

## 3.0.0-rc.1
- 适配DevEco Studio: 4.1 (4.1.3.418), SDK: API11 (4.1.0.56)
- 修复对limitLine1、limitLine2、normalMarker、mData变量进行判空处理
- 修复getCenterOffsets()函数的返回类型
- 修复draw()函数的返回类型
- 修复图例文字太小的问题

## 3.0.0-rc.0
- ohos-MPChart所有组件Canvas重构
- 图表组件使用方式发生改变，具体请参考README.md或demo应用
- 支持自适应调整图表大小
- 支持图表横向滚动功能
- 支持自定义点击、长按等事件功能
- 默认网格线的样式设置，和添加自定义网格线的设置（可设置颜色、线宽、虚线、在轴线的位置）。
- 自定义事件（单击、双击、长按）控制，支持自定义传入@Builder的MarkerView，并支持不同事件触发。
- 自定义设置轴线和文字的样式：轴线颜色、线宽、文字颜色大小，支持y轴延伸线效果

## 2.0.7
- 增加部分接口测试:rect.copyOrNull,rect.equals, barEntry.calcYValsMin

## 2.0.7-rc.3
- 适配IDE4.1(4.1.3.322)和SDK API11(4.1.0.36)

## 2.0.7-rc.2
- 修复柱形图和蜡烛图animateXY卡闪问题
- 修复饼状图每个扇形图标显示超出饼状图问题
- 修复图表放大后x轴超出图表范围
- 修复瀑布图x轴多余坐标

## 2.0.7-rc.1
- 修复x轴左右两侧label文字显示不全的问题
- 修复lineChart有两段数据时，第二段数据的部分节点无法显示的问题

## 2.0.7-rc.0
- 修复LineChart图表实际宽度小于设置宽度的问题
- 修复y轴坐标颜色无法设置的问题
- 修复pieChart中心文字不居中的问题

## 2.0.6

- 修复LineChart图表中Basic图表靠近边框的数值显示不全
- 修复limitLine被数据遮挡住的问题
- 修复设置X轴粗细失效的问题

## 2.0.5

- ArkTS新语法适配

## 2.0.4-rc.0

- 增加各类图表的invalidate刷新功能
- 修复ux规格更改导致旋转手势不生效的问题
- 修复BarWidth失效问题及添加柱状图设置顶部圆角、柱子宽度和居中功能
- 修复app挂机稳定性上报stack overflow问题

## 2.0.3

- 修复setBarWidth接口失效问题
- 修复折线图minOffset设置为0和30时偏移x轴和y轴发生偏移问题
- 修复waterfall表中的radius设置过大，图表数据变成圆点的问题
- 修复waterfall表中数据不设置时，应用闪退的问题

## 2.0.2

- 修复传入values值为空时出现crash问题
- 修改饼状图旋转几圈点击圆饼某块区域不高亮问题
- 修复BarChart动画无限播放的问题
- 修复DevEco Studio: 4.0 Release (4.0.3.411)版本，UX规格更改导致 SwipeGesture 旋转手势不生效的问题
- 修复柱状图setBarWidth不生效问题
- 修复柱状图所有数据为0时界面卡死的问题
- 修复LineChart X轴和Y轴最小坐标输入大于0的数，返回最小坐标还是0的问题
- 添加折线图填充内容显示隐藏线接口
- 添加柱状图设置顶部圆角、柱子宽度和居中功能
- 添加瀑布图效果功能

## 2.0.1

- 适配DevEco Studio: 4.0 Canary2(4.0.3.300), SDK: API10 (4.0.8.6)
- 修复水平条形动画无限播放的bug
- 修复x轴初始坐标非0时，坐标点异常问题
- 修复圆心坐标错误问题，支持自定义圆心修正值

## 2.0.0

- 包管理工具由npm切换为ohpm
- 适配DevEco Studio: 4.0 Canary1(4.0.0.112), SDK: API9 (3.2.12.2)

## 1.1.0

- 适配最小单元刷新
- 适配3.1.0.200IDE

## 1.0.3

修复因导包大小写问题导致编译无法通过的问题

## 1.0.2

- api8升级到api9，并转换为stage模型
- 适配sdk3.2.5.5，修复因sdk版本导致的变量名和组件属性冲突的问题

## 1.0.0

实现了所有自定义图表中的基础显示功能，包含：
1. 曲线图表自定义组件
2. 横向柱形图表自定义组件
3. 竖向柱形图表自定义组件
4. 饼状图表自定义组件
5. 气泡图表自定义组件
6. 蜡烛图表自定义组件
7. 散点图表自定义组件
8. 雷达图自定义组件
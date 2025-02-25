# mpchart

## 简介
mpchart是一个包含各种类型图表的图表库，主要用于业务数据汇总，例如销售数据走势图，股价走势图等场景中使用，方便开发者快速实现图表UI，mpchart主要包括线形图、柱状图、饼状图、蜡烛图、气泡图、雷达图、瀑布图等自定义图表库。

## 效果展示：
![gif](preview/preview.gif)
## 安装教程

```
 ohpm install @ohos/mpchart
```

OpenHarmony ohpm环境配置等更多内容，请参考 [如何安装OpenHarmony ohpm包](https://gitee.com/openharmony-tpc/docs/blob/master/OpenHarmony_har_usage.md) 。

## 使用说明

### 柱状图

1. 柱状图数据初始化：

```
 import {
  BarChart, // 柱状图图表类
  BarChartModel, // 柱状图配置构建类
  BarData, // 柱状图数据包
  BarDataSet, // 柱状图数据集合
  BarEntry, // 柱状图数据结构
  ChartGesture, // 手势事件模式
  Description, // 图表Description(描述)部件
  EntryOhos, // 图表数据结构基础类
  Fill, // 图表填充类型构建类
  Highlight, // 图表高亮数据
  IBarDataSet, // 柱状图数据集合的操作类
  JArrayList, // 工具类：数据集合
  Legend, // 图表Legend(图例)部件
  LimitLabelPosition, // 图表的LimitLine标签位置枚举类
  LimitLine, // 图表LimitLine
  MarkerView, // 图表的Marker(标志气泡)部件
  OnChartGestureListener, // 手势事件监听
  OnChartValueSelectedListener, // 数据选择监听
  XAxis, // 图表X轴部件
  XAxisPosition, // 图表X轴标签位置枚举类
  YAxis, // 图表Y轴部件
  YAxisLabelPosition // 图表Y轴标签位置枚举类
} from '@ohos/mpchart';

// 构造数据选择监听器
  private valueSelectedListener: OnChartValueSelectedListener = {
    onValueSelected: (e: EntryOhos, h: Highlight) => {
    // ...todoSomething
    },
    onNothingSelected: () => {
    // ...todoSomething
    }
  }
  
  // 构造手势识别事件监听器
  private chartGestureListener: OnChartGestureListener = {
    onChartGestureStart: (isTouchEvent: boolean, me: TouchEvent | GestureEvent, lastPerformedGestureMode: ChartGesture) => {
    },
    onChartGestureEnd: (isTouchEvent: boolean, me: TouchEvent | GestureEvent, lastPerformedGestureMode: ChartGesture) => {
    // ...todoSomething
    },
    onChartLongPressed: (isTouchEvent: boolean, me: TouchEvent | GestureEvent) => {
    // ...todoSomething
    },
    onChartDoubleTapped: (isTouchEvent: boolean, me: TouchEvent | GestureEvent) => {
    // ...todoSomething
    },
    onChartSingleTapped: (isTouchEvent: boolean, me: TouchEvent | GestureEvent) => {
    // ...todoSomething
    },
    onChartFling: (isTouchEvent: boolean, me1: TouchEvent | GestureEvent, me2: TouchEvent, velocityX: number, velocityY: number) => {
    // ...todoSomething
    },
    onChartScale: (isTouchEvent: boolean, me: TouchEvent | GestureEvent, scaleX: number, scaleY: number) => {
    // ...todoSomething
    },
    onChartTranslate: (isTouchEvent: boolean, me: TouchEvent | GestureEvent, dX: number, dY: number) => {
    // ...todoSomething
    }
  }
  
  // 图表数据初始化
  aboutToAppear() {
  
  	// Step1:必须：初始化图表配置构建类
    this.model = new BarChartModel();
    
    // Step2:配置图表指定样式，各部件间没有先后之分
    
    // 为图表添加数据选择的监听器
    this.model.setOnChartValueSelectedListener(this.valueSelectedListener);
    // 为图表添加手势识别监听器
    this.model.setOnChartGestureListener(this.chartGestureListener);
	// 获取图表描述部件，设置图表描述部件不可用，即图表不进行绘制描述部件
    let description: Description | null = this.model.getDescription()
    if (description) {
      description.setEnabled(false);
    }
	// 获取图表图例部件，设置图表图例部件不可用
    let l: Legend | null = this.model.getLegend();
    if (l) {
      l.setEnabled(false);
    }
    // 设置图表数据最大的绘制数，如果超过该数值，则不进行绘制图表的数值标签
    this.model.setMaxVisibleValueCount(40);
	// 是否绘制图表的背景色，绘制范围为图表柱状图的绘制范围，不包含轴线之外的部分
    this.model.setDrawGridBackground(false);
    // 设置图表的背景色，颜色的规格需要满足CanvasRenderingContext2D.fillstyle/strokestyle规格
    this.model.setGridBackgroundColor('#500000ff')
    // 设置不绘制柱状图的柱体阴影背景
    this.model.setDrawBarShadow(false);
	// 设置柱状图的数值在柱体上方
    this.model.setDrawValueAboveBar(false);
    // 设置柱状图的高亮范围是否为整个柱体，只在堆叠柱状图中有区别
    this.model.setHighlightFullBarEnabled(false);
	// 为左Y轴设置LimitLine,可设置限制线的宽度，线段样式，限制标签的位置，标签字体大小等
    this.limitLine1 = new LimitLine(120, 'Upper Limit');
    this.limitLine1.setLineWidth(4);
    this.limitLine1.enableDashedLine(10, 10, 0);
    this.limitLine1.setLabelPosition(LimitLabelPosition.RIGHT_TOP);
    this.limitLine1.setTextSize(10);

    this.limitLine2 = new LimitLine(50, 'Lower Limit');
    this.limitLine2.setLineWidth(4);
    this.limitLine2.enableDashedLine(10, 10, 0);
    this.limitLine2.setLineColor(Color.Yellow);
    this.limitLine2.setLabelPosition(LimitLabelPosition.RIGHT_BOTTOM);
    this.limitLine2.setTextSize(10);

    // 设置图表左Y轴信息
    this.leftAxis = this.model.getAxisLeft();
    if (this.leftAxis) {
      this.leftAxis.setAxisMinimum(0); // this replaces setStartAtZero(true)
      this.leftAxis.setDrawLimitLinesBehindData(false);

      // 添加LimitLines
      this.leftAxis.addLimitLine(this.limitLine1);
      this.leftAxis.addLimitLine(this.limitLine2);
    }
	// 设置图表右Y轴信息
    this.rightAxis = this.model.getAxisRight();
    if (this.rightAxis) {
      this.rightAxis.setEnabled(false);
      this.rightAxis.setAxisMinimum(0);
    }
	// 设置X轴信息
    this.xAxis = this.model.getXAxis();
    if (this.xAxis) {
      this.xAxis.setPosition(XAxisPosition.BOTTOM);
    }
	// 为图表设置markerView
    this.normalMarker = new MarkerView();
    this.model.setMarker(this.normalMarker);
    // 也可设置定义图表MarkerView
    this.stackMarker = new CustomMarkerView();
	// 生成单一颜色数据
    this.data = this.getNormalData();
    // 将数据与图表配置类绑定
    this.model.setData(this.data);
    // 设置图表最大的X轴显示范围，如不设置，则默认显示全部数据
    this.model.setVisibleXRangeMaximum(20);
  }

   private getNormalData(): BarData {
    let values: JArrayList<BarEntry> = new JArrayList<BarEntry>();
    values.add(new BarEntry(1, 73.3));
    values.add(new BarEntry(2, 5.4));

    let dataSet: BarDataSet = new BarDataSet(values, 'DataSet');
    dataSet.setHighLightColor(Color.Black);
    dataSet.setDrawIcons(false);
    // 为柱体添加颜色信息
    dataSet.setColorByColor(Color.Pink);

    let dataSetList: JArrayList<IBarDataSet> = new JArrayList<IBarDataSet>();
    dataSetList.add(dataSet);

    let barData: BarData = new BarData(dataSetList);
    //设置柱状图宽度
    barData.setBarWidth(0.85);
    //设置顶部圆角半径
    barData.setTopRadius(5);
    return barData;
  }

  private getGradientData(): BarData {
    let values: JArrayList<BarEntry> = new JArrayList<BarEntry>();
    values.add(new BarEntry(1, 32.9));
    values.add(new BarEntry(2, 44.7));

    let dataSet: BarDataSet = new BarDataSet(values, 'DataSet');
    dataSet.setHighLightColor(Color.Black);
    dataSet.setDrawIcons(false);
    let startColor1: string = '#ffffbb33';
    let startColor2: string = '#ff33b5e5';
    let startColor3: string = '#ffffbb33';
    let startColor4: string = '#ff99cc00';
    let startColor5: string = '#ffff4444';
    let endColor1: string = '#ff0099cc';
    let endColor2: string = '#ffaa66cc';
    let endColor3: string = '#ff669900';
    let endColor4: string = '#ffcc0000';
    let endColor5: string = '#ffff8800';
    let gradientFills: JArrayList<Fill> = new JArrayList<Fill>();
    gradientFills.add(new Fill(startColor1, endColor1));
    gradientFills.add(new Fill(startColor2, endColor2));
    gradientFills.add(new Fill(startColor3, endColor3));
    gradientFills.add(new Fill(startColor4, endColor4));
    gradientFills.add(new Fill(startColor5, endColor5));
	// 为柱体添加渐变的颜色信息
    dataSet.setFills(gradientFills);

    let dataSetList: JArrayList<IBarDataSet> = new JArrayList<IBarDataSet>();
    dataSetList.add(dataSet);

    let barData: BarData = new BarData(dataSetList);
    barData.setBarWidth(0.85);
    return barData;
  }

  private getStackData(): BarData {
    let values: JArrayList<BarEntry> = new JArrayList<BarEntry>();
    values.add(new BarEntry(1, [38.0, 28.0, 39.8]));
    values.add(new BarEntry(2, [18.2, 16.1, 16.1]));

    let set1: BarDataSet | null = null;
    set1 = new BarDataSet(values, "Statistics Vienna 2014");
    set1.setDrawIcons(false);
    // 为柱体添加指定分段的颜色信息
    set1.setColorsByArr([Color.Red, Color.Green, Color.Pink]);
    set1.setStackLabels(["Births", "Divorces", "Marriages"]);

    let dataSets: JArrayList<IBarDataSet> = new JArrayList<IBarDataSet>();
    dataSets.add(set1);

    let data: BarData = new BarData(dataSets);
    data.setValueTextColor(Color.White);
    return data;
  }
```

2. 添加数据到自定义竖向柱状图表组件

```
// 为组件设置配置构建类，如果需要在页面初始化就显示图表，则需要在aboutToAppear方法中完成图表数据构建
// 如果在之后通过事件触发，
// 可通过barData.notifyDataSetChanged();来触发数据更新，
// 可通过this.model.notifyDataSetChanged();来触发坐标轴数据更新，
// 可通过this.model.invalidate();来触发绘制更新。
BarChart({ model: this.model })
  .width('100%')
  .height('30%')
```

### 线形图

1. 线形图数据初始化：

```
import {
  JArrayList, // 工具类：数据集合
  XAxis, // 图表X轴部件
  XAxisPosition, // 图表X轴标签位置枚举类
  YAxis, // 图表Y轴部件
  Description, // 图表描述标签
  Legend, // 图表Legend(图例)部件
  OnChartValueSelectedListener, //
  Highlight,// 图表高亮数据
  EntryOhos,// 图表数据结构基础类
  YAxisLabelPosition,// 图表Y轴标签位置枚举类
  LineDataSet, //线形图数据集合
  ILineDataSet, // 线形图数据集合的操作类
  LineData, //线形图数据包
  Mode, //线形图形状
  LineChart, // 线形图图表类
  LineChartModel,// 线形图配置构建类
  LimitLine, // 图表LimitLine
  LimitLabelPosition, // 图表的LimitLine标签位置枚举类
  ChartColorStop, //颜色类
  LegendForm, //图例形状
} from '@ohos/mpchart';

// 构造数据选择监听器
  private valueSelectedListener: OnChartValueSelectedListener = {
    onValueSelected: (e: EntryOhos, h: Highlight) => {
    // ...todoSomething
    },
    onNothingSelected: () => {
    // ...todoSomething
    }
  }
  
  // 图表数据初始化
  aboutToAppear() {
  
  	// Step1:必须：初始化图表配置构建类
    this.model = new LineChartModel();
    
    // Step2:配置图表指定样式，各部件间没有先后之分
    
    // 为图表添加数据选择的监听器
    this.model.setOnChartValueSelectedListener(this.valueSelectedListener);
	// 获取图表描述部件，设置图表描述部件不可用，即图表不进行绘制描述部件
    let description: Description | null = this.model.getDescription()
    if (description) {
      description.setEnabled(false);
    }
    
	// 获取图表图例部件，设置图表图例形状为线形
    let legend: Legend | null = this.model.getLegend();
    if (legend) {
      legend.setEnabled(true);
      // draw legend entries as lines
      legend.setForm(LegendForm.LINE);
    }
    
    // 设置图表数据最大的绘制数，如果超过该数值，则不进行绘制图表的数值标签
    this.model.setMaxVisibleValueCount(60);
    
	// 为左Y轴设置LimitLine,可设置限制线的宽度，线段样式，限制标签的位置，标签字体大小等
    this.limitLine1 = new LimitLine(120, 'Upper Limit');
    this.limitLine1.setLineWidth(4);
    //设置虚线样式
    this.limitLine1.enableDashedLine(10, 10, 0);
    //设置标签位置
    this.limitLine1.setLabelPosition(LimitLabelPosition.RIGHT_TOP);
    this.limitLine1.setTextSize(10);

    this.limitLine2 = new LimitLine(50, 'Lower Limit');
    this.limitLine2.setLineWidth(4);
    this.limitLine2.enableDashedLine(10, 10, 0);
    this.limitLine2.setLineColor(Color.Yellow);
    this.limitLine2.setLabelPosition(LimitLabelPosition.RIGHT_BOTTOM);
    this.limitLine2.setTextSize(10);

    // 设置图表左Y轴信息
    this.leftAxis = this.model.getAxisLeft();
    if (this.leftAxis) {
      //设置绘制标签个数
      this.leftAxis.setLabelCount(8, false);
      //设置标签位置
      this.leftAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART)
      //设置距离顶部距离
      this.leftAxis.setSpaceTop(15);
      //设置最大值
      this.leftAxis.setAxisMinimum(0);
      //设置最小值
      this.leftAxis.setAxisMaximum(200);
    }

	// 设置图表右Y轴信息
    this.rightAxis = this.model.getAxisRight();
    if (this.rightAxis) {
      this.rightAxis.setLabelCount(8, false);
      this.rightAxis.setDrawGridLines(false);
      this.rightAxis.setSpaceTop(15);
      this.rightAxis.setAxisMinimum(0);
      this.rightAxis.setAxisMaximum(200);
      this.rightAxis.setEnabled(false);
    }
    
	// 设置X轴信息
        this.xAxis = this.model.getXAxis();
    if (this.xAxis) {
      this.xAxis.setPosition(XAxisPosition.BOTTOM);
      this.xAxis.setDrawGridLines(false);
      this.xAxis.setGranularity(1);
      this.xAxis.setLabelCount(7);
    }
    
	// 为图表设置markerView
    this.normalMarker = new MarkerView();
    this.model.setMarker(this.normalMarker);
    // 也可设置定义图表MarkerView
    this.stackMarker = new CustomMarkerView();
    // 生成图表数据
    let lineData: LineData = this.getLineData();
    // 将数据与图表配置类绑定
    this.model.setData(lineData);
    // 设置图表最大的X轴显示范围，如不设置，则默认显示全部数据
    this.model.setVisibleXRangeMaximum(20);
  }

   private getLineData(): LineData {

    let start: number = 1;
    let values: JArrayList<EntryOhos> = new JArrayList<EntryOhos>();
    for (let i = start; i < 20; i++) {
      let val = Number(Math.random() * 141);

      if (Math.random() * 100 < 25) {
        values.add(new EntryOhos(i, val));
      } else {
        values.add(new EntryOhos(i, val));
      }
    }

    this.dataSet = new LineDataSet(values, 'DataSet');
    this.dataSet.setHighLightColor(Color.Black);
    this.dataSet.setDrawIcons(false);

    this.dataSet.setMode(Mode.LINEAR); //直线模式
    this.dataSet.setDrawCircles(true); //折线点画圆圈
    this.dataSet.setDrawCircleHole(false); //设置内部孔
    this.dataSet.setColorByColor(Color.Black); //设置折线颜色

    //渐变色填充
    let gradientFillColor = new JArrayList<ChartColorStop>();
    gradientFillColor.add(["#0C0099CC", 0.2]);
    gradientFillColor.add(["#7F0099CC", 0.4]);
    gradientFillColor.add(["#0099CC", 1.0]);
    this.dataSet.setGradientFillColor(gradientFillColor);
    this.dataSet.setDrawFilled(true);


    // 设置数据点的颜色
    this.dataSet.setCircleColor(Color.Blue); // 可以设置为你想要的颜色

    // 设置数据点的半径
    this.dataSet.setCircleRadius(4); // 设置半径大小
    this.dataSet.setCircleHoleRadius(2); //设置内径

    let dataSetList: JArrayList<ILineDataSet> = new JArrayList<ILineDataSet>();
    dataSetList.add(this.dataSet);

    let lineData: LineData = new LineData(dataSetList);
    return lineData
  }
  
```

2. 添加数据到自定义线形图表组件

```
// 为组件设置配置构建类，如果需要在页面初始化就显示图表，则需要在aboutToAppear方法中完成图表数据构建
// 如果在之后通过事件触发，
// 可通过lineData.notifyDataSetChanged();来触发数据更新，
// 可通过this.model.notifyDataSetChanged();来触发坐标轴数据更新，
// 可通过this.model.invalidate();来触发绘制更新。
LineChart({ model: this.model })
  .width('100%')
  .height('30%')
```

### 饼状图

1. 饼状图数据初始化：

```
   import {
     ChartGesture,         // 图表手势
     ColorTemplate,        // 颜色模板
     EntryOhos,            // 图表数据结构基础类
     Highlight,            // 高亮
     IPieDataSet,          // 饼状图数据集接口
     JArrayList,           // 工具类：数据集合
     Legend,               // 图表Legend(图例)部件
     MPPointF,             // MPPointF
     OnChartGestureListener,   // 图表手势监听器接口
     OnChartValueSelectedListener,  // 图表数值选择监听器接口
     PieChart,             // 饼状图组件
     PieChartModel,        // 饼状图配置构建类
     PieData,              // 饼状图数据包
     PieDataSet,           // 饼状图数据集合
     PieEntry,             // 饼状图数据结构
   } from '@ohos/mpchart';
  
  // 图表数据初始化
  
  // Step1:必须：初始化图表配置构建类
  private model: PieChartModel = new PieChartModel();
    
  aboutToAppear() {
    // Step2：配置图表的特定样式，各部件间没有先后之分

    let l: Legend | null = this.model.getLegend();
    if (l) {
      l.setEnabled(true);
    }
    this.model.animateX(1000);  // 启用X轴动画效果，动画持续时间为1000毫秒
    this.model.setUsePercentValues(true);  // 使用百分比值
    this.model.getDescription()?.setEnabled(false);  // 禁用描述信息
    this.model.setExtraOffsets(5, 10, 5, 5);  // 设置额外偏移量

    this.model.setOnChartGestureListener(this.chartGestureListener);  // 设置图表手势监听器

    this.model.setDragDecelerationFrictionCoef(0.95);  // 设置拖动减速摩擦系数

    this.model.setCenterText("mpchart");  // 设置中心文本
    this.model.setCenterTextSize(22);  // 设置中心文本大小

    this.model.setDrawHoleEnabled(true);  // 启用绘制中心孔
    this.model.setHoleColor(Color.White);  // 设置中心孔颜色

    this.model.setTransparentCircleColor(Color.Red);  // 设置透明圆环颜色
    this.model.setTransparentCircleAlpha(110);  // 设置透明圆环透明度

    this.model.setHoleRadius(58);  // 设置中心孔半径
    this.model.setTransparentCircleRadius(61);  // 设置透明圆环半径

    this.model.setDrawCenterText(true);  // 绘制中心文本

    this.model.setRotationAngle(0);  // 设置旋转角度
    // 通过触摸启用图表的旋转
    this.model.setRotationEnabled(true);
    this.model.setHighlightPerTapEnabled(true);  // 启用点击高亮效果

    this.setData(4, 10);  // 设置图表数据
  }

   // 初始化饼状图数据
  private setData(count: number, range: number): void {
    let entries: JArrayList<PieEntry> = new JArrayList<PieEntry>();

    // NOTE: The order of the entries when being added to the entries array determines their position around the center of
    // the chart.
    for (let i = 0; i < count; i++) {
      entries.add(new PieEntry(((Math.random() * range) + range / 5),
        this.parties[i % this.parties.length], undefined, undefined));
    }

    // 创建饼状图数据集对象，设置数据项和数据集名称
    let dataSet: PieDataSet = new PieDataSet(entries, "Election Results");
    // 设置是否绘制数据项图标
    dataSet.setDrawIcons(false);
    // 设置数据项之间的间隙
    dataSet.setSliceSpace(1);
    // 设置数据项图标的偏移量
    dataSet.setIconsOffset(new MPPointF(0, 40));
    // 设置选中时数据项的偏移距离
    dataSet.setSelectionShift(5);
    // 设置数据项文本颜色
    dataSet.setValueTextColor(Color.White);


    // add a lot of colors
    let colors: JArrayList<number> = new JArrayList();
    for (let index = 0; index < ColorTemplate.VORDIPLOM_COLORS.length; index++) {
      colors.add(ColorTemplate.VORDIPLOM_COLORS[index]);
    }

    for (let index = 0; index < ColorTemplate.JOYFUL_COLORS.length; index++) {
      colors.add(ColorTemplate.JOYFUL_COLORS[index]);
    }

    for (let index = 0; index < ColorTemplate.COLORFUL_COLORS.length; index++) {
      colors.add(ColorTemplate.COLORFUL_COLORS[index]);
    }
    for (let index = 0; index < ColorTemplate.LIBERTY_COLORS.length; index++) {
      colors.add(ColorTemplate.LIBERTY_COLORS[index]);
    }
    for (let index = 0; index < ColorTemplate.PASTEL_COLORS.length; index++) {
      colors.add(ColorTemplate.PASTEL_COLORS[index]);
    }
    colors.add(ColorTemplate.getHoloBlue());
    dataSet.setColorsByList(colors);
    // 生成图表数据
    let data: PieData = new PieData(dataSet);
    // 将数据与图表配置类绑定
    this.model.setData(data);
  }
  
```

2. 添加数据到自定义饼状图图表组件

```
// 为组件设置配置构建类，如果需要在页面初始化就显示图表，则需要在aboutToAppear方法中完成图表数据构建
// 如果在之后通过事件触发，
// 可通过dataSet.notifyDataSetChanged();来触发数据更新，
// 可通过this.model.notifyDataSetChanged();来触发坐标轴数据更新，
// 可通过this.model.invalidate();来触发绘制更新。
PieChart({ model: this.model })
  .width('100%')
  .height('70%')
```

### 气泡图

1. 气泡图数据初始化：

```
   // 导入一些图表相关的组件和类
   import {
     JArrayList,  //工具类：数据集合
     XAxis,  // 图表X轴部件
     XAxisPosition,  // 图表X轴标签位置枚举类
     YAxis,  // 图表Y轴部件
     Description,  // 图表的描述信息
     Legend,  // 图例
     OnChartValueSelectedListener,  // 图表数值选中的监听器
     Highlight,  // 高亮显示
     EntryOhos,  // 图表数据结构基础类
     YAxisLabelPosition,  // 图表Y轴标签位置枚举类
     BubbleEntry,  // 气泡图数据结构
     ChartPixelMap,  // 图表像素映射
     IBubbleDataSet,  // 气泡图数据集的接口
     BubbleDataSet,  // 气泡图数据集
     MPPointF,  // MPPonitF
     BubbleChart,  // 气泡图组件
     BubbleChartModel,  // 气泡图配置构建类
     BubbleData  // 气泡图数据
   } from '@ohos/mpchart';
  
  // 构造数据选择监听器
  private valueSelectedListener: OnChartValueSelectedListener = {
    onValueSelected: (e: EntryOhos, h: Highlight) => {
    // ...todoSomething
    },
    onNothingSelected: () => {
    // ...todoSomething
    }
  }
  
  // 图表数据初始化
  private model: BubbleChartModel | null = null;
    
  aboutToAppear() {
    // Step1:必须：初始化图表配置构建类
    this.model = new BubbleChartModel();
    // Step2：配置图表的特定样式，各部件间没有先后之分

    //设置图例
    let l: Legend | null = this.model.getLegend();
    if (l) {
      l.setEnabled(true);
    }
    
    //设置描述
    let description: Description | null = this.model.getDescription();
    if (description) {
      description.setEnabled(false);
    }

    // 设置最大可见条目数量为60
   this.model.setMaxVisibleValueCount(60);
   
   // 禁用x和y轴方向同时缩放，但是可以单独x轴方向或者y轴方向缩放
   this.model.setPinchZoom(false);
   
   // 获取X轴对象
   let xAxis: XAxis | null = this.model.getXAxis();
   if (xAxis) {
     // 设置X轴位置在底部
     xAxis.setPosition(XAxisPosition.BOTTOM);
     
     // 不绘制X轴网格线
     xAxis.setDrawGridLines(false);
   
     // 设置X轴坐标的最小间隔为1
     xAxis.setGranularity(1);
   
     // 设置X轴标签数量为7
     xAxis.setLabelCount(7);
   }
   
   // 获取左侧Y轴对象
   let leftAxis: YAxis | null = this.model.getAxisLeft();
   if (leftAxis) {
     // 设置左侧Y轴标签数量为8，不强制使用整数标签
     leftAxis.setLabelCount(8, false);
     
     // 设置左侧Y轴标签位置在图表外部
     leftAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART);
     
     // 设置顶部空白区域为15个单位
     leftAxis.setSpaceTop(15);
     
     // 设置左侧Y轴的最小值为0
     leftAxis.setAxisMinimum(0);
   }
   
   // 获取右侧Y轴对象
   let rightAxis: YAxis | null = this.model.getAxisRight();
   if (rightAxis) {
     // 设置右侧Y轴标签数量为8，不强制使用整数标签
     rightAxis.setLabelCount(8, false);
     
     // 不绘制右侧Y轴网格线
     rightAxis.setDrawGridLines(false);
     
     // 设置顶部空白区域为15个单位
     rightAxis.setSpaceTop(15);
     
     // 设置右侧Y轴的最小值为0
     rightAxis.setAxisMinimum(0);
   }
   
   // 初始化起始值为1
   let start: number = 1;
   
   // 创建气泡图数据集
   let values: JArrayList<BubbleEntry> = new JArrayList<BubbleEntry>();
   for (let i = start; i < 20; i++) {
     // 生成随机值（0到40之间）
     let val = Number(Math.random() * 41);
   
     // 按照一定概率添加气泡数据
     if (Math.random() * 100 < 25) {
       values.add(new BubbleEntry(i, val));
     } else {
       values.add(new BubbleEntry(i, val));
     }
   }
   
   // 创建气泡图数据集
   let dataSet: BubbleDataSet = new BubbleDataSet(values, 'DataSet');
   dataSet.setHighLightColor(Color.Black);
   dataSet.setDrawIcons(false);
   
   // 创建气泡图数据集列表
   let dataSetList: JArrayList<IBubbleDataSet> = new JArrayList<IBubbleDataSet>();
   dataSetList.add(dataSet);
   
   // 设置图表数据
   this.setData(5, 50);
   
   // 设置图表最大的X轴显示范围为7个单位
   this.model.setVisibleXRangeMaximum(7);

  }

   // 初始化气泡图数据
     /**
    * 设置气泡图表的数据
    * @param count 数据点的数量
    * @param range 数据点的范围
    */
   private setData(count: number, range: number): void {

    // 创建三个气泡图数据集
    let values1 = new JArrayList<BubbleEntry>();
    let values2 = new JArrayList<BubbleEntry>();
    let values3 = new JArrayList<BubbleEntry>();
    
    // 创建图标绘制对象
    let imgePaint: ChartPixelMap = new ChartPixelMap();

    // 设置图标的宽度和高度
    imgePaint.setWidth(32);
    imgePaint.setHeight(32);

    // 循环生成数据点
    for (let i = 0; i < count; i++) {
      // 向数据集添加带有图标的气泡数据点
      values1.add(new BubbleEntry(i, Math.random() * range, Math.random() * range, imgePaint));
      values2.add(new BubbleEntry(i, Math.random() * range, Math.random() * range, imgePaint));
      
      // 向数据集添加不带图标的气泡数据点
      values3.add(new BubbleEntry(i, Math.random() * range, Math.random() * range));
    }

    // 创建气泡数据集1
    let set1: BubbleDataSet = new BubbleDataSet(values1, "DS 1");
    set1.setDrawIcons(false);
    set1.setColorByColor(0x88c12552);
    set1.setIconsOffset(new MPPointF(0, 0));
    set1.setDrawValues(this.isDrawValuesEnable);

    // 创建气泡数据集2
    let set2: BubbleDataSet = new BubbleDataSet(values2, "DS 2");
    set2.setDrawIcons(false);
    set2.setIconsOffset(new MPPointF(0, 0));
    set2.setColorByColor(0x88ff6600);
    set2.setDrawValues(this.isDrawValuesEnable);

    // 创建气泡数据集3
    let set3: BubbleDataSet = new BubbleDataSet(values3, "DS 3");
    set3.setDrawIcons(false);
    set3.setIconsOffset(new MPPointF(0, 0));
    set3.setColorByColor(0x88f5c700);
    set3.setDrawValues(this.isDrawValuesEnable);

    // 创建气泡图数据集列表
    let dataSets = new JArrayList<IBubbleDataSet>();
    dataSets.add(set1);
    dataSets.add(set2);
    dataSets.add(set3);

    // 创建气泡图数据对象
    let dataResult: BubbleData = new BubbleData(dataSets);
    dataResult.setDrawValues(this.isDrawValuesEnable);
    dataResult.setValueTextSize(8);
    dataResult.setValueTextColor(Color.White);
    dataResult.setHighlightCircleWidth(1.5);
    dataResult.setHighlightEnabled(true);
    dataResult.notifyDataChanged();

    // 如果存在图表模型，则设置图表数据
    if (this.model) {
      this.model.setData(dataResult);
    }
   }  
  
```

2. 添加数据到自定义气泡图图表组件

```
// 为组件设置配置构建类，如果需要在页面初始化就显示图表，则需要在aboutToAppear方法中完成图表数据构建
// 如果在之后通过事件触发，
// 可通过dataResult.notifyDataSetChanged();来触发数据更新，
// 可通过this.model.notifyDataSetChanged();来触发坐标轴数据更新，
// 可通过this.model.invalidate();来触发绘制更新。
BubbleChart({ model: this.model })
  .width('100%')
  .height('70%')
```

### 蜡烛图

1. 蜡烛图数据初始化：

```
   // 导入一些图表相关的组件和类
   import {
     AxisDependency, // 轴依赖类
     CandleData, // 蜡烛图数据包
     CandleDataSet, // 蜡烛图数据集合
     CandleEntry, // 蜡烛图数据结构
     CandleStickChart, // 蜡烛图图表类
     CandleStickChartModel, // 蜡烛图配置构建类
     ChartPixelMap, // 图表像素映射类
     Description, // 图表Description(描述)部件
     JArrayList, // 工具类：数据集合
     Legend, // 图表Legend(图例)部件
     Style, // 图表样式类
     XAxis, // 图表X轴部件
     XAxisPosition, // 图表X轴标签位置枚举类
     YAxis // 图表Y轴部件
   } from '@ohos/mpchart';
    
  aboutToAppear() {
    // 图表数据初始化
    // Step1:必须：初始化图表配置构建类
    this.model = new CandleStickChartModel();
    
    // Step2：配置图表的特定样式，各部件间没有先后之分
    //设置描述
    let description: Description | null = this.model.getDescription();
    if (description) {
      description.setEnabled(false);
    }

    //设置图例
    let l: Legend | null = this.model.getLegend();
    if (l) {
      l.setEnabled(true);
    }
    
      this.model.setMaxVisibleValueCount(60);  // 设置图表最大可见数值数量为60
      this.model.setPinchZoom(false);  // 禁用捏合缩放
      this.model.setDrawGridBackground(true);  // 启用绘制网格背景
      this.model.setGridBackgroundColor(Color.White);  // 设置网格背景颜色为白色
      this.setData(40, 100);  // 设置图表数据
      
      let xAxis: XAxis | null = this.model.getXAxis();
      if (xAxis) {
        xAxis.setPosition(XAxisPosition.BOTTOM);  // 设置X轴位置在底部
        xAxis.setDrawGridLines(true);  // 启用绘制X轴网格线
      }
      
      let leftAxis: YAxis | null = this.model.getAxisLeft();
      if (leftAxis) {
        leftAxis.setLabelCount(7, false);  // 设置左侧Y轴标签数量为7，不强制使用整数标签
        leftAxis.setDrawGridLines(true);  // 启用绘制左侧Y轴网格线
        leftAxis.setDrawAxisLine(true);  // 启用绘制左侧Y轴轴线
      }
      
      let rightAxis: YAxis | null = this.model.getAxisRight();
      if (rightAxis) {
        rightAxis.setLabelCount(7, false);  // 设置右侧Y轴标签数量为7，不强制使用整数标签
        rightAxis.setDrawGridLines(true);  // 启用绘制右侧Y轴网格线
        rightAxis.setDrawAxisLine(true);  // 启用绘制右侧Y轴轴线
      }
      
      let legend: Legend | null = this.model.getLegend();
      if (legend) {
        legend.setEnabled(true);  // 启用图例
      }
  }

   // 初始化蜡烛图数据
    private setData(count: number, range: number):void{

    let values: JArrayList<CandleEntry> = new JArrayList<CandleEntry>();

    for (let i = 0; i < count; i++) {
      let val: number = (Math.random() * 40) + (range + 3);

      let high: number = Number(Math.random() * 9) + 8.0;
      let low: number = Number(Math.random() * 9) + 8.0;

      let open: number = Number(Math.random() * 6) + 1.0;
      let close: number = Number(Math.random() * 6) + 1.0;

      let even: boolean = i % 2 == 0;

      values.add(new CandleEntry(
        i,
        val + high,
        val - low,
        even ? val + open : val - open,
        even ? val - close : val + close,
        new ChartPixelMap()));
    }

      // 创建蜡烛图数据集，并设置数据集的名称为 "Data Set"
      let dataSet: CandleDataSet = new CandleDataSet(values, "Data Set");
      // 设置是否绘制图标为 false
      dataSet.setDrawIcons(false);
      // 设置数据集的轴依赖为左侧Y轴
      dataSet.setAxisDependency(AxisDependency.LEFT);
      // 设置蜡烛图阴影颜色为灰色
      dataSet.setShadowColor(Color.Gray);
      // 设置蜡烛图阴影宽度为 0.7
      dataSet.setShadowWidth(0.7);
      // 设置蜡烛图下跌蜡烛的绘制样式为填充
      dataSet.setDecreasingPaintStyle(Style.FILL);
      // 设置蜡烛图下跌蜡烛的颜色为红色
      dataSet.setDecreasingColor(Color.Red);
      // 设置蜡烛图上涨蜡烛的颜色为绿色
      dataSet.setIncreasingColor(Color.Green);
      // 设置蜡烛图上涨蜡烛的绘制样式为描边
      dataSet.setIncreasingPaintStyle(Style.STROKE);
      // 设置蜡烛图中性蜡烛的颜色为蓝色
      dataSet.setNeutralColor(Color.Blue);

    let data: CandleData = new CandleData([dataSet]);
    data.setValueTextSize(7);
    if (this.model) {
      this.model.resetTracking();
      this.model.setData(data);
    }
  }
  
```

### 组合图

1. 组合图数据初始化：

```
   // 导入一些图表相关的组件和类
   import {
     ColorTemplate,  // 颜色模板
     CombinedChart,  // 组合图表类
     CombinedChartModel,  // 组合图表配置构建类
     CombinedData,  // 组合图表数据包
     EntryOhos,  // 图表数据结构基础类
     JArrayList,  // 工具类：数据集合
     LineData,  // 折线图数据包
     LineDataSet,  // 折线图数据集合
     Color,  // 颜色类
     Mode,  // 图表模式枚举类
     AxisDependency,  // 轴依赖类
     BarEntry,  // 柱状图数据结构
     BarData,  // 柱状图数据包
     BarDataSet,  // 柱状图数据集合
     IBarDataSet,  // 柱状图数据集合的操作类
     ScatterData,  // 散点图数据包
     ScatterDataSet,  // 散点图数据集合
     CandleData,  // 蜡烛图数据包
     CandleEntry,  // 蜡烛图数据结构
     CandleDataSet,  // 蜡烛图数据集合
     BubbleData,  // 气泡图数据包
     BubbleEntry,  // 气泡图数据结构
     BubbleDataSet,  // 气泡图数据集合
     YAxisLabelPosition,  // 图表Y轴标签位置枚举类
     XAxisPosition,  // 图表X轴标签位置枚举类
     XAxis,  // 图表X轴部件
     YAxis,  // 图表Y轴部件
     LegendHorizontalAlignment,  // 图例水平对齐方式枚举类
     LegendVerticalAlignment  // 图例垂直对齐方式枚举类
   } from '@ohos/mpchart';

   // Step1:必须：初始化图表配置构建类
   private model: CombinedChartModel = new CombinedChartModel();
    
   aboutToAppear() {
    // Step2：配置图表的特定样式，各部件间没有先后之分
    
    // 禁用图表描述
    this.model.getDescription()?.setEnabled(false);

    // 获取图例对象
    let l = this.model.getLegend();
    if (l) {
      // 启用图例
      l.setEnabled(true);
      
      // 启用图例文字自动换行
      l.setWordWrapEnabled(true);
      
      // 设置图例水平对齐方式为左侧
      l.setHorizontalAlignment(LegendHorizontalAlignment.LEFT);
      
      // 设置图例垂直对齐方式为底部
      l.setVerticalAlignment(LegendVerticalAlignment.BOTTOM);
      
      // 设置图例不绘制在图表内部
      l.setDrawInside(false);
    }

    // 设置图表最大可见数值数量为60
    this.model.setMaxVisibleValueCount(60);

    // 禁用图表的捏合缩放功能
    this.model.setPinchZoom(false);

    // 禁用图表绘制网格背景
    this.model.setDrawGridBackground(false);

    // 获取X轴对象
    let xAxis: XAxis | null = this.model.getXAxis();
    if (xAxis) {
      // 设置X轴位置在底部
      xAxis.setPosition(XAxisPosition.BOTTOM);
      
      // 不绘制X轴网格线
      xAxis.setDrawGridLines(false);
      
      // 设置X轴坐标的最小间隔为1
      xAxis.setGranularity(1);
      
      // 设置X轴标签数量为7
      xAxis.setLabelCount(7);
    }

    // 获取左侧Y轴对象
    let leftAxis: YAxis | null = this.model.getAxisLeft();
    if (leftAxis) {
      // 设置左侧Y轴标签数量为8，不强制使用整数标签
      leftAxis.setLabelCount(8, false);
      
      // 设置左侧Y轴标签位置在图表外部
      leftAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART);
      
      // 设置顶部空白区域为15个单位
      leftAxis.setSpaceTop(15);
      
      // 设置左侧Y轴的最小值为0
      leftAxis.setAxisMinimum(0);
    }

    // 获取右侧Y轴对象
    let rightAxis: YAxis | null = this.model.getAxisRight();
    if (rightAxis) {
      // 设置右侧Y轴标签数量为8，不强制使用整数标签
      rightAxis.setLabelCount(8, false);
      
      // 不绘制右侧Y轴网格线
      rightAxis.setDrawGridLines(false);
      
      // 设置顶部空白区域为15个单位
      rightAxis.setSpaceTop(15);
      
      // 设置右侧Y轴的最小值为0
      rightAxis.setAxisMinimum(0);
    }

    // 创建组合图表数据对象
    let data: CombinedData = new CombinedData();
    
    // 生成线形图数据
    this.generateLineData(data);
    
    // 生成柱状图数据
    this.generateBarData(data);
    
    // 生成气泡图数据
    this.generateBubbleData(data);
    
    // 生成散点图数据
    this.generateScatterData(data);
    
    // 生成蜡烛图数据
    this.generateCandleData(data);
    
    // 设置图表数据
    this.model.setData(data);
  }

   // 生成线形图数据
    private generateLineData(data: CombinedData): void {

    let d: LineData = new LineData();

    let entries: JArrayList<EntryOhos> = new JArrayList();

    for (let index = 0; index < this.count; index++) {

      entries.add(new EntryOhos(index + 0.5, this.getRandom(15, 5)));
    }

    let set: LineDataSet = new LineDataSet(entries, "Line DataSet");
    set.setColorByColor(Color.rgb(240, 238, 70));
    set.setLineWidth(2.5);
    set.setCircleColor(Color.rgb(240, 238, 70));
    set.setCircleRadius(5);
    set.setFillColor(Color.rgb(240, 238, 70));
    set.setMode(Mode.CUBIC_BEZIER);
    set.setDrawValues(true);
    set.setValueTextSize(10);
    set.setValueTextColor(Color.rgb(240, 238, 70));

    set.setAxisDependency(AxisDependency.LEFT);
    d.addDataSet(set);
    data.setLineData(d);

  }
  
  // 生成柱状图数据
  private generateBarData(data: CombinedData): void {

    let entries1: JArrayList<BarEntry> = new JArrayList();
    let entries2: JArrayList<BarEntry> = new JArrayList();

    for (let index = 0; index < this.count; index++) {
      entries1.add(new BarEntry(0, this.getRandom(25, 25)));

      // stacked
      entries2.add(new BarEntry(0, [this.getRandom(13, 12), this.getRandom(13, 12)]));
    }

    let set1: BarDataSet = new BarDataSet(entries1, "Bar 1");
    set1.setColorByColor(Color.rgb(60, 220, 78));
    set1.setValueTextColor(Color.rgb(60, 220, 78));
    set1.setValueTextSize(10);
    set1.setAxisDependency(AxisDependency.LEFT);

    let set2: BarDataSet = new BarDataSet(entries2, "");
    set2.setStackLabels(["Stack 1", "Stack 2"]);
    set2.setColorsByArr([Color.rgb(61, 165, 255), Color.rgb(23, 197, 255)]);
    set2.setValueTextColor(Color.rgb(61, 165, 255));
    set2.setValueTextSize(10);
    set2.setAxisDependency(AxisDependency.LEFT);

    let groupSpace = 0.06;
    let barSpace = 0.02; // x2 dataset
    let barWidth = 0.45; // x2 dataset
    // (0.45 + 0.02) * 2 + 0.06 = 1.00 -> interval per "group"

    let set: JArrayList<IBarDataSet> = new JArrayList();
    set.add(set1);
    set.add(set2);
    let d: BarData = new BarData(set);
    d.setBarWidth(barWidth);

    // make this BarData object grouped
    d.groupBars(0, groupSpace, barSpace); // start at x = 0
    data.setBarData(d);

  }

  // 生成散点图数据
  private generateScatterData(data: CombinedData): void {

    let d: ScatterData = new ScatterData();

    let entries: JArrayList<EntryOhos> = new JArrayList();

    for (let index = 0; index < this.count; index += 0.5)
      entries.add(new EntryOhos(index + 0.25, this.getRandom(10, 55)));

    let set: ScatterDataSet = new ScatterDataSet(entries, "Scatter DataSet");
    set.setColorsByArr(ColorTemplate.MATERIAL_COLORS);
    set.setScatterShapeSize(7.5);
    set.setDrawValues(false);
    set.setValueTextSize(10);
    d.addDataSet(set);
    data.setScatterData(d);
  }

   // 生成蜡烛图数据
  private generateCandleData(data: CombinedData): void {

    let d: CandleData = new CandleData();

    let entries: JArrayList<CandleEntry> = new JArrayList();

    for (let index = 0; index < this.count; index += 2) {

      entries.add(new CandleEntry(index + 1, 90, 70, 85, 75));
    }

    let set: CandleDataSet = new CandleDataSet(entries, "Candle DataSet");
    set.setDecreasingColor(Color.rgb(142, 150, 175));
    set.setShadowColor(ColorTemplate.DKGRAY);
    set.setBarSpace(0.3);
    set.setValueTextSize(10);
    set.setDrawValues(false);
    d.addDataSet(set);
    data.setCandleData(d);
  }

  //生成气泡图数据
  private generateBubbleData(data: CombinedData): void {

    let bd: BubbleData = new BubbleData();

    let entries: JArrayList<BubbleEntry> = new JArrayList();

    for (let index = 0; index < this.count; index++) {
      let y = this.getRandom(10, 105);
      let size = this.getRandom(20, 30);
      entries.add(new BubbleEntry(index + 0.5, y, size));
    }

    let set: BubbleDataSet = new BubbleDataSet(entries, "Bubble DataSet");
    set.setColorsByArr(ColorTemplate.VORDIPLOM_COLORS);
    set.setValueTextSize(10);
    set.setValueTextColor(Color.rgb(255, 255, 255));
    set.setHighlightCircleWidth(1.5);
    set.setDrawValues(true);
    bd.addDataSet(set);
    data.setBubbleData(bd);
  }
  //生成随机数据
  getRandom(range: number, start: number): number {
    return (Math.random() * range) + start;
  }

```

2. 添加数据到自定义组合图图表组件

```
// 为组件设置配置构建类，如果需要在页面初始化就显示图表，则需要在aboutToAppear方法中完成图表数据构建
// 如果在之后通过事件触发，
// 可通过data.notifyDataSetChanged();来触发数据更新，
// 可通过this.model.notifyDataSetChanged();来触发坐标轴数据更新，
// 可通过this.model.invalidate();来触发绘制更新。
CombinedChart({ model: this.model })
  .width('100%')
  .height('70%')
```

### 雷达图

1. 雷达图数据初始化：

```
   // 导入一些图表相关的组件和类
   import {
     ChartColor,  // 图表颜色类
     JArrayList,  // 工具类：数据集合
     XAxis,  // 图表X轴部件
     XAxisPosition,  // 图表X轴标签位置枚举类
     Description,  // 图表Description(描述)部件
     Legend,  // 图表Legend(图例)部件
     OnChartValueSelectedListener,  // 数据选择监听
     Highlight,  // 图表高亮数据
     EntryOhos,  // 图表数据结构基础类
     RadarEntry,  // 雷达图数据结构
     RadarChart,  // 雷达图图表类
     RadarDataSet,  // 雷达图数据集合
     RadarChartModel,  // 雷达图配置构建类
     IRadarDataSet,  // 雷达图数据集合的操作类
     RadarData,  // 雷达图数据包
     YAxis,  // 图表Y轴部件
     IAxisValueFormatter,  // 轴数值格式化接口
     AxisBase,  // 轴基础类
     LegendVerticalAlignment,  // 图例垂直对齐方式枚举类
     LegendHorizontalAlignment,  // 图例水平对齐方式枚举类
     LegendOrientation,  // 图例方向枚举类
   } from '@ohos/mpchart';
    
    // Step1:必须：初始化图表配置构建类
    private model: RadarChartModel = new RadarChartModel();
    
   aboutToAppear() {
    // Step2：配置图表的特定样式，各部件间没有先后之分
    // 设置雷达图数值选择监听器
    this.model.setOnChartValueSelectedListener(this.valueSelectedListener);

    // 获取图表描述对象
    let description: Description | null = this.model.getDescription();
    if (description) {
      // 禁用图表描述
      description.setEnabled(false);
    }

    // 获取图例对象
    let l: Legend | null = this.model.getLegend();
    if (l) {
      // 启用图例
      l.setEnabled(true);
      
      // 设置图例垂直对齐方式为顶部
      l.setVerticalAlignment(LegendVerticalAlignment.TOP);
      
      // 设置图例水平对齐方式为居中
      l.setHorizontalAlignment(LegendHorizontalAlignment.CENTER);
      
      // 设置图例方向为水平
      l.setOrientation(LegendOrientation.HORIZONTAL);
      
      // 设置图例不绘制在图表内部
      l.setDrawInside(false);
      
      // 设置图例X轴方向间隔
      l.setXEntrySpace(7);
      
      // 设置图例Y轴方向间隔
      l.setYEntrySpace(5);
      
      // 设置图例文字颜色为白色
      l.setTextColor(Color.White);
    }

    // 设置雷达图网格线宽度、颜色和透明度
    this.model.setWebLineWidth(0.3);
    this.model.setWebColor(0xFFCCCCCC);
    this.model.setWebLineWidthInner(0.3);
    this.model.setWebColorInner(0xFFCCCCCC);
    this.model.setWebAlpha(100);

    // 设置雷达图顶部的额外偏移量
    this.model.setExtraTopOffset(-100);

    // 创建雷达图标记视图对象
    this.normalMarker = new RadarMarkerView();
    
    // 设置雷达图标记
    this.model.setMarker(this.normalMarker);

    // 获取X轴对象
    let xAxis: XAxis | null = this.model.getXAxis();
    if (xAxis) {
      // 设置X轴位置在底部
      xAxis.setPosition(XAxisPosition.BOTTOM);
      
      // 不绘制X轴网格线
      xAxis.setDrawGridLines(false);
      
      // 设置X轴标签文字大小
      xAxis.setTextSize(20);
      
      // 设置X轴Y轴方向的偏移量
      xAxis.setYOffset(0);
      xAxis.setXOffset(0);
      
      // 设置X轴坐标的最小间隔为1
      xAxis.setGranularity(1);
      
      // 设置X轴标签数量为7
      xAxis.setLabelCount(7);
      
      // 设置X轴数值格式化器
      xAxis.setValueFormatter(new valueFormatter());
      
      // 设置X轴标签文字颜色为白色
      xAxis.setTextColor(Color.White);
    }

    // 获取Y轴对象
    let yAxis: YAxis | null = this.model.getYAxis();
    if (yAxis) {
      // 设置Y轴标签数量为5，不强制使用整数标签
      yAxis.setLabelCount(5, false);
      
      // 设置Y轴标签文字大小
      yAxis.setTextSize(20);
      
      // 设置Y轴的最小值为0
      yAxis.setAxisMinimum(0);
      
      // 设置Y轴的最大值为80
      yAxis.setAxisMaximum(80);
      
      // 不绘制Y轴标签
      yAxis.setDrawLabels(false);
    }

    // 设置雷达图数据
    this.setData();
  }

   /**
   * 设置雷达图的数据
   */
   private setData(): void {
    let mul = 80;  // 随机值的放大倍数
    let min = 20;  // 随机值的最小基准
    let cnt = 5;   // 数据点数量

    // 创建雷达图数据点集合
    let entries1: JArrayList<RadarEntry> = new JArrayList<RadarEntry>();
    let entries2: JArrayList<RadarEntry> = new JArrayList<RadarEntry>();

    // 注意: 将数据点添加到数据点数组中的顺序决定它们在图表中心周围的位置。
    for (let i = 0; i < cnt; i++) {
      let val1 = (Math.random() * mul) + min;
      entries1.add(new RadarEntry(val1));

      let val2 = (Math.random() * mul) + min;
      entries2.add(new RadarEntry(val2));
    }

    // 创建雷达图数据集
    let set1: RadarDataSet = new RadarDataSet(entries1, "Last Week");
    set1.setColorByColor(ChartColor.rgb(103, 110, 129));
    set1.setFillColor(ChartColor.rgb(103, 110, 129));
    set1.setDrawFilled(true);
    set1.setFillAlpha(180);
    set1.setLineWidth(2);
    set1.setDrawHighlightCircleEnabled(true);
    set1.setDrawHighlightIndicators(false);

    // 创建雷达图数据集
    let set2: RadarDataSet = new RadarDataSet(entries2, "This Week");
    set2.setColorByColor(ChartColor.rgb(121, 162, 175));
    set2.setFillColor(ChartColor.rgb(121, 162, 175));
    set2.setDrawFilled(true);
    set2.setFillAlpha(180);
    set2.setLineWidth(2);
    set2.setDrawHighlightCircleEnabled(true);
    set2.setDrawHighlightIndicators(false);

    // 创建雷达图数据集合
    let sets: JArrayList<IRadarDataSet> = new JArrayList<IRadarDataSet>();
    sets.add(set1);
    sets.add(set2);

    // 创建雷达图数据对象
    let data: RadarData = new RadarData(sets);
    data.setValueTextSize(20);
    
    // 不绘制数据值
    data.setDrawValues(false);
    
    // 设置数据值文字颜色为白色
    data.setValueTextColor(Color.White);
    
    // 设置图表数据
    this.model.setData(data);
   }


```

2. 添加数据到雷达图图表组件

```
// 为组件设置配置构建类，如果需要在页面初始化就显示图表，则需要在aboutToAppear方法中完成图表数据构建
// 如果在之后通过事件触发，
// 可通过data.notifyDataSetChanged();来触发数据更新，
// 可通过this.model.notifyDataSetChanged();来触发坐标轴数据更新，
// 可通过this.model.invalidate();来触发绘制更新。
RadarChart({ model: this.model })
  .width('100%')
  .height('70%')
```

### 散点图

1. 散点图数据初始化：

```
   // 导入一些图表相关的组件和类
   import {
     JArrayList,  // 工具类：数据集合
     XAxis,  // 图表X轴部件
     XAxisPosition,  // 图表X轴标签位置枚举类
     YAxis,  // 图表Y轴部件
     Description,  // 图表Description(描述)部件
     Legend,  // 图表Legend(图例)部件
     OnChartValueSelectedListener,  // 数据选择监听
     Highlight,  // 图表高亮数据
     EntryOhos,  // 图表数据结构基础类
     YAxisLabelPosition,  // 图表Y轴标签位置枚举类
     ScatterChart,  // 散点图图表类
     ScatterChartModel,  // 散点图配置构建类
     ScatterData,  // 散点图数据包
     ScatterDataSet,  // 散点图数据集合
     IScatterDataSet,  // 散点图数据集合的操作类
     ColorTemplate,  // 颜色模板
     ChartShape,  // 图表形状枚举类
   } from '@ohos/mpchart';

    
   aboutToAppear() {
    // Step1:必须：初始化图表配置构建类
    this.model = new ScatterChartModel();

    // Step2：配置图表的特定样式，各部件间没有先后之分
    // 获取图例对象
    let l: Legend | null = this.model.getLegend();
    if (l) {
      // 启用图例
      l.setEnabled(true);
    }
    
    // 设置散点图数值选择监听器
    this.model.setOnChartValueSelectedListener(this.valueSelectedListener);

    // 获取描述对象
    let description: Description | null = this.model.getDescription();
    if (description) {
      // 禁用图表描述
      description.setEnabled(false);
    }

    // 设置图表最大可见数值数量、是否支持缩放、是否绘制网格背景
    this.model.setMaxVisibleValueCount(160);
    this.model.setPinchZoom(false);
    this.model.setDrawGridBackground(false);

    // 获取X轴对象
    let xAxis: XAxis | null = this.model.getXAxis();
    if (xAxis) {
      // 设置X轴位置在底部
      xAxis.setPosition(XAxisPosition.BOTTOM);
      
      // 不绘制X轴网格线
      xAxis.setDrawGridLines(false);
      
      // 设置X轴坐标的最小间隔为1
      xAxis.setGranularity(1);
      
      // 设置X轴标签数量为7
      xAxis.setLabelCount(7);
    }

    // 获取左侧Y轴对象
    let leftAxis: YAxis | null = this.model.getAxisLeft();
    if (leftAxis) {
      // 设置左侧Y轴标签数量为8，不强制使用整数标签
      leftAxis.setLabelCount(8, false);
      
      // 设置左侧Y轴标签位置在图表外部
      leftAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART);
      
      // 设置左侧Y轴顶部空白区域大小
      leftAxis.setSpaceTop(15);
      
      // 设置左侧Y轴的最小值为0
      leftAxis.setAxisMinimum(0);
    }

    // 获取右侧Y轴对象
    let rightAxis: YAxis | null = this.model.getAxisRight();
    if (rightAxis) {
      // 设置右侧Y轴标签数量为8，不绘制右侧Y轴网格线
      rightAxis.setLabelCount(8, false);
      rightAxis.setDrawGridLines(false);
      
      // 设置右侧Y轴顶部空白区域大小
      rightAxis.setSpaceTop(15);
      
      // 设置右侧Y轴的最小值为0
      rightAxis.setAxisMinimum(0);
    }

    // 生成随机数据
    let start: number = 1;
    let values: JArrayList<EntryOhos> = new JArrayList<EntryOhos>();
    for (let i = start; i < 20; i++) {
      let val = Number(Math.random() * 41);

      if (Math.random() * 100 < 25) {
        values.add(new EntryOhos(i, val));
      } else {
        values.add(new EntryOhos(i, val));
      }
    }

    // 创建散点图数据集
    let dataSet: ScatterDataSet = new ScatterDataSet(values, 'DataSet');
    dataSet.setHighLightColor(Color.Black);
    dataSet.setDrawIcons(false);

    // 创建散点图数据集合
    let dataSetList: JArrayList<IScatterDataSet> = new JArrayList<IScatterDataSet>();
    dataSetList.add(dataSet);

    // 设置图表数据
    this.setData(20, 100);
  }
   
   /**
    * 设置散点图数据
    * @param xRange - X轴数据范围
    * @param yRange - Y轴数据范围
    */
   private setData(xRange: number, yRange: number): void {
   
       // 生成随机数据集合
       let values1 = this.generateRandomData(xRange, yRange);
       let values2 = this.generateRandomData(xRange, yRange);
       let values3 = this.generateRandomData(xRange, yRange);
   
       // 创建散点图数据集1
       let set1 = new ScatterDataSet(values1, "DS 1");
       set1.setScatterShape(ChartShape.SQUARE);
       set1.setColorByColor(ColorTemplate.COLORFUL_COLORS[0]);
   
       // 创建散点图数据集2
       let set2 = new ScatterDataSet(values2, "DS 2");
       set2.setScatterShape(ChartShape.CIRCLE);
       set2.setScatterShapeHoleColor(ColorTemplate.COLORFUL_COLORS[3]);
       set2.setScatterShapeHoleRadius(3);
       set2.setColorByColor(ColorTemplate.COLORFUL_COLORS[1]);
   
       // 创建散点图数据集3
       let set3 = new ScatterDataSet(values3, "DS 3");
       set3.setShapeRenderer(new CustomScatterShapeRenderer());
       set3.setColorByColor(ColorTemplate.COLORFUL_COLORS[2]);
   
       // 设置散点图数据集形状大小
       set1.setScatterShapeSize(8);
       set2.setScatterShapeSize(8);
       set3.setScatterShapeSize(8);
   
       // 创建散点图数据集合
       let dataSets: JArrayList<IScatterDataSet> = new JArrayList<IScatterDataSet>();
       dataSets.add(set1); // 添加数据集
       dataSets.add(set2);
       dataSets.add(set3);
   
       // 创建散点图数据
       let dataResult: ScatterData = new ScatterData(dataSets);
       dataResult.setDrawValues(this.isDrawValuesEnable);
       dataResult.setValueTextSize(8);
       dataResult.setHighlightEnabled(true);
   
       // 设置数据项文本大小
       dataResult.setValueTextSize(10);
   
       // 设置图表数据
       if (this.model) {
         this.model.setData(dataResult);
       }
   }

   /**
    * 生成随机散点图数据
    * @param xRange - X轴数据范围
    * @param yRange - Y轴数据范围
    * @returns 随机散点图数据集合
    */
   private generateRandomData(xRange: number, yRange: number): JArrayList<EntryOhos> {
       let values = new JArrayList<EntryOhos>();
   
       // 循环生成随机数据
       for (let i = 0; i < xRange; i++) {
         let x = i; // 在指定范围内生成随机X值
         let y = Math.random() * yRange; // 在指定范围内生成随机Y值
         values.add(new EntryOhos(x, y));
       }
       return values;
   }

```

2. 添加数据到散点图图表组件

```
// 为组件设置配置构建类，如果需要在页面初始化就显示图表，则需要在aboutToAppear方法中完成图表数据构建
// 如果在之后通过事件触发，
// 可通过dataResult.notifyDataSetChanged();来触发数据更新，
// 可通过this.model.notifyDataSetChanged();来触发坐标轴数据更新，
// 可通过this.model.invalidate();来触发绘制更新。
ScatterChart({ model: this.model })
  .width('100%')
  .height('70%')
```
### 瀑布图

1. 瀑布图数据初始化：

```
 import {
  WaterfallChart, // 瀑布图图表类
  WaterfallChartModel, // 瀑布图配置构建类
  BarData, // 瀑布图数据包
  WaterfallDataSet, // 瀑布图数据集合
  WaterfallEntry, // 瀑布图数据结构
  ChartGesture, // 手势事件模式
  Description, // 图表Description(描述)部件
  EntryOhos, // 图表数据结构基础类
  Fill, // 图表填充类型构建类
  Highlight, // 图表高亮数据
  IBarDataSet, // 瀑布图数据集合的操作类
  JArrayList, // 工具类：数据集合
  Legend, // 图表Legend(图例)部件
  LimitLabelPosition, // 图表的LimitLine标签位置枚举类
  LimitLine, // 图表LimitLine
  MarkerView, // 图表的Marker(标志气泡)部件
  OnChartGestureListener, // 手势事件监听
  OnChartValueSelectedListener, // 数据选择监听
  XAxis, // 图表X轴部件
  XAxisPosition, // 图表X轴标签位置枚举类
  YAxis, // 图表Y轴部件
  YAxisLabelPosition // 图表Y轴标签位置枚举类
} from '@ohos/mpchart';

   // 构造数据选择监听器
   private valueSelectedListener: OnChartValueSelectedListener = {
    onValueSelected: (e: EntryOhos, h: Highlight) => {
      LogUtil.log("SimpleWaterfallChartPage onValueSelected: " + e.getX());
    },
    onNothingSelected: () => {
      LogUtil.log("SimpleWaterfallChartPage onNothingSelected");
    }
  }
  
  // 构造手势识别事件监听器
  private chartGestureListener: OnChartGestureListener = {
    onChartGestureStart: (isTouchEvent: boolean, me: TouchEvent | GestureEvent, lastPerformedGestureMode: ChartGesture) => {
    },
    onChartGestureEnd: (isTouchEvent: boolean, me: TouchEvent | GestureEvent, lastPerformedGestureMode: ChartGesture) => {
    // ...todoSomething
    },
    onChartLongPressed: (isTouchEvent: boolean, me: TouchEvent | GestureEvent) => {
    // ...todoSomething
    },
    onChartDoubleTapped: (isTouchEvent: boolean, me: TouchEvent | GestureEvent) => {
    // ...todoSomething
    },
    onChartSingleTapped: (isTouchEvent: boolean, me: TouchEvent | GestureEvent) => {
    // ...todoSomething
    },
    onChartFling: (isTouchEvent: boolean, me1: TouchEvent | GestureEvent, me2: TouchEvent, velocityX: number, velocityY: number) => {
    // ...todoSomething
    },
    onChartScale: (isTouchEvent: boolean, me: TouchEvent | GestureEvent, scaleX: number, scaleY: number) => {
    // ...todoSomething
    },
    onChartTranslate: (isTouchEvent: boolean, me: TouchEvent | GestureEvent, dX: number, dY: number) => {
    // ...todoSomething
    }
  }
  
  // 图表数据初始化
  aboutToAppear() {
  
  	// Step1:必须：初始化图表配置构建类
    this.model = new WaterfallChartModel();
    
    // Step2:配置图表指定样式，各部件间没有先后之分
    
    // 为图表添加数据选择的监听器
    this.model.setOnChartValueSelectedListener(this.valueSelectedListener);
    // 为图表添加手势识别监听器
    this.model.setOnChartGestureListener(this.chartGestureListener);
	// 获取图表描述部件，设置图表描述部件不可用，即图表不进行绘制描述部件
    let description: Description | null = this.model.getDescription()
    if (description) {
      description.setEnabled(false);
    }
	// 获取图表图例部件，设置图表图例部件不可用
    let l: Legend | null = this.model.getLegend();
    if (l) {
      l.setEnabled(false);
    }
    // 设置图表数据最大的绘制数，如果超过该数值，则不进行绘制图表的数值标签
    this.model.setMaxVisibleValueCount(40);
	// 是否绘制图表的背景色，绘制范围为图表瀑布图的绘制范围，不包含轴线之外的部分
    this.model.setDrawGridBackground(false);
    // 设置图表的背景色，颜色的规格需要满足CanvasRenderingContext2D.fillstyle/strokestyle规格
    this.model.setGridBackgroundColor('#500000ff')
    // 设置不绘制瀑布图的柱体阴影背景
    this.model.setDrawBarShadow(false);
	// 设置瀑布图的数值在柱体上方
    this.model.setDrawValueAboveBar(false);
	// 为左Y轴设置LimitLine,可设置限制线的宽度，线段样式，限制标签的位置，标签字体大小等
    this.limitLine1 = new LimitLine(120, 'Upper Limit');
    this.limitLine1.setLineWidth(4);
    this.limitLine1.enableDashedLine(10, 10, 0);
    this.limitLine1.setLabelPosition(LimitLabelPosition.RIGHT_TOP);
    this.limitLine1.setTextSize(10);

    this.limitLine2 = new LimitLine(50, 'Lower Limit');
    this.limitLine2.setLineWidth(4);
    this.limitLine2.enableDashedLine(10, 10, 0);
    this.limitLine2.setLineColor(Color.Yellow);
    this.limitLine2.setLabelPosition(LimitLabelPosition.RIGHT_BOTTOM);
    this.limitLine2.setTextSize(10);

    // 设置图表左Y轴信息
    this.leftAxis = this.model.getAxisLeft();
    if (this.leftAxis) {
      this.leftAxis.setAxisMinimum(0); // this replaces setStartAtZero(true)
      this.leftAxis.setDrawLimitLinesBehindData(false);

      // 添加LimitLines
      this.leftAxis.addLimitLine(this.limitLine1);
      this.leftAxis.addLimitLine(this.limitLine2);
    }
	// 设置图表右Y轴信息
    this.rightAxis = this.model.getAxisRight();
    if (this.rightAxis) {
      this.rightAxis.setEnabled(false);
      this.rightAxis.setAxisMinimum(0);
    }
	// 设置X轴信息
    this.xAxis = this.model.getXAxis();
    if (this.xAxis) {
      this.xAxis.setPosition(XAxisPosition.BOTTOM);
    }
	// 为图表设置markerView
    this.normalMarker = new MarkerView();
    this.model.setMarker(this.normalMarker);
    // 也可设置定义图表MarkerView
    this.stackMarker = new CustomMarkerView();
	// 生成单一颜色数据
    this.data = this.getNormalData();
    
    // 按Y轴刻度范围绘制多种颜色数据
    this.data = this.getSegmentationData();
    
    // 高亮最高点最低点数据
    this.data = this.getTopAndBottomHighlightData();
    
    // 将数据与图表配置类绑定
    this.model.setData(this.data);
    // 设置图表最大的X轴显示范围，如不设置，则默认显示全部数据
    this.model.setVisibleXRangeMaximum(20);
  }
  
   private getNormalData(): BarData {
    let values: JArrayList<WaterfallEntry> = new JArrayList<WaterfallEntry>();
    // 设置标记点位置及颜色
    let h1 = new WaterfallHighlight(20, 30, Color.Gray);
    let h2 = new WaterfallHighlight(30, 40, Color.Gray);
    let h3 = new WaterfallHighlight(40, 60, Color.Green);
    let h4 = new WaterfallHighlight(60, 70, Color.Red);

    values.add(new WaterfallEntry(1, 10, 30, undefined, undefined, h1));
    values.add(new WaterfallEntry(2, 15, 50));
    values.add(new WaterfallEntry(4, 5, 95, undefined, undefined, h2, h3, h4));
    values.add(new WaterfallEntry(6, 45, 80, undefined, undefined, h2, h3));

    this.dataSet = new WaterfallDataSet(values, 'DataSet');
    this.dataSet.setHighLightColor(Color.Gray);
    this.dataSet.setDrawIcons(false);
    // 为柱体添加颜色信息
    this.dataSet.setColorByColor(Color.Pink);
    this.dataSet.setValueTextSize(10)

    let dataSetList: JArrayList<IBarDataSet> = new JArrayList<IBarDataSet>();
    dataSetList.add(this.dataSet);

    let barData: BarData = new BarData(dataSetList);
    //设置瀑布图宽度
    barData.setBarWidth(0.3);
     //设置顶部圆角半径
    barData.setTopRadius(1);
    return barData;
  }

  private getSegmentationData(): BarData {
     let values: JArrayList<WaterfallEntry> = new JArrayList<WaterfallEntry>();

    values.add(new WaterfallEntry(1, 10, 70));
    values.add(new WaterfallEntry(2, 15, 80));

    this.dataSet = new WaterfallDataSet(values, 'DataSet');
    this.dataSet.setHighLightColor(Color.Gray);
    this.dataSet.setDrawIcons(false);
    this.dataSet.setColorByColor(Color.Pink);
    this.dataSet.setValueTextSize(10)

    // 根据Y刻度范围设置颜色
    let highlightList: WaterfallHighlight[] = [];
    highlightList.push(new WaterfallHighlight(0, 40, Color.Green));
    highlightList.push(new WaterfallHighlight(40, 60, Color.Orange));
    highlightList.push(new WaterfallHighlight(60, 100, Color.Pink));
    this.dataSet.setYAxisSegmentationColors(highlightList);

    let dataSetList: JArrayList<IBarDataSet> = new JArrayList<IBarDataSet>();
    dataSetList.add(this.dataSet);

    let barData: BarData = new BarData(dataSetList);
    barData.setBarWidth(0.3);
    return barData;
  }
  
  private getTopAndBottomHighlightData(): BarData {
    let values: JArrayList<WaterfallEntry> = new JArrayList<WaterfallEntry>();
    let highlightList: WaterfallHighlight[] = [];
    // Y刻度范围颜色设置
    highlightList.push(new WaterfallHighlight(0, 40, Color.Green));
    highlightList.push(new WaterfallHighlight(40, 60, Color.Orange));
    highlightList.push(new WaterfallHighlight(60, 100, Color.Pink));

    // 瀑布图数据封装
    values.add(new WaterfallEntry(1, 10, 90));
    values.add(new WaterfallEntry(2, 15, 80));
    values.add(new WaterfallEntry(3, 20, 90));

    this.dataSet = new WaterfallDataSet(values, 'DataSet');
    // 设置瀑布图选中时颜色
    this.dataSet.setHighLightColor(Color.Gray);
    this.dataSet.setDrawIcons(false);
    // 设置瀑布图颜色
    this.dataSet.setColorByColor(Color.Pink);
    // Y刻度范围颜色设置
     this.dataSet.setYAxisSegmentationColors(highlightList);
    // 最高点最低点是否高亮
    this.dataSet.setEnableMaxOrMinHighlightColor(true);
    // 最高点高亮时颜色设置
    this.dataSet.setMaxyHighlightColor(Color.Brown);
    // 最低点高亮时颜色设置
    this.dataSet.setMinyHighlightColor(Color.Yellow);

    let dataSetList: JArrayList<IBarDataSet> = new JArrayList<IBarDataSet>();
    dataSetList.add(this.dataSet);

    let barData: BarData = new BarData(dataSetList);
    barData.setBarWidth(0.3);
    return barData;
  }
```
2. 添加数据到瀑布图表组件

```
// 为组件设置配置构建类，如果需要在页面初始化就显示图表，则需要在aboutToAppear方法中完成图表数据构建
// 如果在之后通过事件触发，
// 可通过dataResult.notifyDataSetChanged();来触发数据更新，
// 可通过this.model.notifyDataSetChanged();来触发坐标轴数据更新，
// 可通过this.model.invalidate();来触发绘制更新。
WaterfallChart({ model: this.model })
  .width('100%')
  .height('70%')
```

### 添加自定义图标(以柱状图为例)

```
    let charPixelMap: ChartPixelMap = new ChartPixelMap();
    let fileData = resourceMgr.getMediaContentSync($r('app.media.star').id)
    const buffer:ArrayBuffer =fileData.buffer.slice(0,fileData.buffer.byteLength);
    const imageSource = image.createImageSource(buffer)
    let pixelMap=await imageSource.createPixelMap()
    //设置自定义图标资源 PixelMap
    charPixelMap.setIcon(pixelMap)
    //设置自定义图标资源 resId
    //charPixelMap.setIcon($r('app.media.star').id)
    //设置自定义图标宽度
    charPixelMap.setWidth(20)
     //设置自定义图标高度
    charPixelMap.setHeight(20);

    let values: JArrayList<BarEntry> = new JArrayList<BarEntry>();
    for (let i = startAxis; i < endAxis; i++) {
      values.add(new BarEntry(i, Math.random() * range,charPixelMap))
    }

    let dataSet: BarDataSet = new BarDataSet(values, 'DataSet');
    dataSet.setHighLightColor(Color.Black);
    //设置显示自定义图标
    dataSet.setDrawIcons(true);
    //设置自定义图标偏移量
    dataSet.setIconsOffset(new MPPointF(0, 40));
    dataSet.setColorsByVariable(ColorTemplate.VORDIPLOM_COLORS);
    dataSet.setDrawValues(false)
```


### 自定义图表

1. 定制数据结构

   图表数据分为三层 ，分别对应基类：EntryOhos, DataSet,ChartData

   - CustomEntry: 定制图表基础数据实体

     继承自EntryOhos,类，对外提供数据实体类的属性的get,set方法。

   - CustomDataSet: 定制图表实体的集合类

     继承自DataSet, 描述一组实体信息，每个entry通用的属性可在此类中配置及处理，如获取数据集合中的X轴/Y轴最大最小值，设置图表高亮颜色等。

   - CustomData: 定制图表数据容器

     继承自ChartData,处理通用的实体集合(Dataset)的信息，如计算获取最终显示时的X轴/Y轴最大最小值，或者如柱状图的柱体宽度等。

2. 定制图表配置构建类

   继承自ChartModel基础类，根据需要可以继承子类BarLineChartBaseModel，PieRadarChartBaseModel，同时需要实现各自图表的 DataProvoder接口，主要用于获取图表数据容器CustomData，DataProvider 继承自ChartInterface。

   图表配置构建类，需要重写以下重要方法：

   - setContext2D  <font color='red'>必须</font>

     由于图表绘制依赖于Canvas组件，所以需要在绘制的流程中获取到绑定到Canvas组件上的操作上下文CanvasRenderingContext2D，通过此方法将Canvas的操作上下文与图表绘制流程进行绑定，用于后续图表绘制操作。

     ```
     public setContext2D(context2d: CanvasRenderingContext2D) {
       this.context2d = context2d;
     }
     ```

   - onChartSizeChanged   <font color='red'>必须</font>

     如果想要在页面初始化时就显示图表，需要在aboutToAppear()方法中进行图表数据构建及配置，例如此种情况下，图表绘制流程获取到的组件宽高数据就是不正确的。

     所以需要Canvas组件完成布局之后通过监听组件Size变化回调onAreaChange()通知绘制流程根据组件当前正确的Size进行计算缩放比例，坐标校正等。

     ```
     public onChartSizeChanged(newWidth: number, newHeight: number, oldWidth: number, oldHeight: number) {
       super.onSizeChanged(newWidth, newHeight, oldWidth, oldHeight);
     }
     ```

   - invalidate   <font color='red'>必须</font>

     用于手动触发图表重新绘制，如图表数据，轴边界，显示设置更新等操作之后，需要手动触发重新绘制，刷新最新显示效果。

     ```
     public invalidate(): void {
       if (this.context2d) {
         super.onDraw(this.context2d);
       }
     }
     ```

   - init   <font color='red'>必须</font>

     此方法用于初始化图表的各个部件及其渲染类

     定制部件如：XAxis，YAxis，Description，Legend等，

     定制坐标转换类如：Transformer

     定制渲染类如：XAxisRenderer,YAxisRenderer,DataRenderer等。

     ```
     public init(): void {
       super.init();
     
       this.mRenderer = new BarChartRenderer(this, this.mAnimator!, this.mViewPortHandler);
     
       this.setHighlighter(new BarHighlighter(this));
     
       let xAxis : XAxis | null = this.getXAxis();
       if (xAxis) {
         xAxis.setSpaceMin(0.5);
         xAxis.setSpaceMax(0.5);
       }
     }
     ```

   - onDraw   <font color='red'>必须</font>

     用于规定图表绘制流程，一般BarLineChartBaseModel，PieRadarChartBaseModel基本符合绘制要求，也可根据业务进行定制，每次图表刷新本质上就是调用此方法进行重新绘制。

     <font color='red'>注意</font>

     不要在onDraw方法做耗时操作;

     不要在onDraw方法中新建对象;

3. 定制图表部件

   图表各部件(Description，Legend，LimitLine，XAxis，YAxis)都继承自基类ComponentBase，提供图表部件的基础属性，xOffset，yOffset，enabled，textSize，textColor等，同时各部件可以根据特性进行添加定制属性，如X轴/Y轴通过calculate()计算出预期的坐标轴最大最小值（与Dataset里面的最大最小值可能会有差异，X轴/Y轴的最大最小值可以设置预留空间）。

   ```
   /**
    * 计算要显示的坐标轴最大最小值
    * @param dataMin: 实际的数据最小值
    * @param dataMax: 实际的数据最大值
    */
   public calculate(dataMin: number, dataMax: number): void {
   
     // if custom, use value as is, else use data value
     let min: number = this.mCustomAxisMin ? this.mAxisMinimum : (dataMin - this.mSpaceMin);
     let max: number = this.mCustomAxisMax ? this.mAxisMaximum : (dataMax + this.mSpaceMax);
   
     // temporary range (before calculations)
     let range: number = Math.abs(max - min);
   
     // in case all values are equal
     if (range == 0) {
       max = max + 1;
       min = min - 1;
     }
   
     this.mAxisMinimum = min;
     this.mAxisMaximum = max;
   
     // actual range
     this.mAxisRange = Math.abs(max - min);
   }
   ```

4. 定制渲染类

   CustomXAxisRenderer/CustomYAxisRenderer ：坐标轴渲染器

   - computeAxis

     根据配置信息判断是否需要再次校正要显示的X轴/Y轴的最大最小值

     ```
     /**
      * X轴渲染器计算要显示的X轴最小值和最大值
      * @param min : XAxis的calculate中计算获取的预期显示的X轴刻度最小值
      * @param max : XAxis的calculate中计算获取的预期显示的X轴刻度最大值
      * @param inverted: 是否反转坐标轴
      */
     public computeAxis(min: number, max: number, inverted: boolean) {
     
       // calculate the starting and entry point of the y-labels (depending on
       // zoom / contentrect bounds)
       if (!this.mViewPortHandler || !this.mTrans) {
         return;
       }
       
       // 如果修改过X轴比例，则根据当前组件宽度，和scalex重新计算新的X轴最大最小值
       if (this.mViewPortHandler.contentWidth() > 10 && !this.mViewPortHandler.isFullyZoomedOutX()) {
     
         let p1: MPPointD | undefined = this.mTrans?.getValuesByTouchPoint(this.mViewPortHandler.contentLeft(), this.mViewPortHandler.contentTop());
         let p2: MPPointD | undefined = this.mTrans?.getValuesByTouchPoint(this.mViewPortHandler.contentRight(), this.mViewPortHandler.contentTop());
     
         if (!!p1 && !!p2) {
           if (inverted) {
     
             min = p2.x;
             max = p1.x;
           } else {
     
             min = p1.x;
             max = p2.x;
           }
     
           MPPointD.recycleInstance(p1);
           MPPointD.recycleInstance(p2);
         }
       }
     
       this.computeAxisValues(min, max);
     }
     ```

   - computeAxisValues

     根据确定好的X轴/Y轴的最大最小值，再进行计算在最大最小值之间应该显示多少个刻度标签，对应的值都应该是多少。

   - renderAxisLabels

     用于绘制坐标轴的刻度标签。

   - renderGridLines

     用于绘制坐标轴的网格线。

   - renderAxisLine

     用于绘制坐标轴的轴线。

   - renderLimitLines

     用于绘制坐标轴数据的限制线。

   CustomDataRender：数据渲染器

   - initBuffers

     用于处理图表的缓存数据，此方法会分配内存，请谨慎使用，非必要不要使用此方法。

   - drawData

     用于绘制图表，将数据转换为图形。

   - drawValues

     用于绘制图表数据数值显示。

   - drawExtras

     额外绘制图表内容。

   - drawHighlighted

     绘制图表高亮显示样式。

5. 定制图表组件

   图表绘制基于Canvas组件实现，所以自定义的图表布局需要包含Canvas画布，在Canvas的onReady中开启绘制，通过onAreaChange回调方法校正图表Size。

   ```
   import CustomModel from '../xx/CustomModel';
   
   @Component
   export struct CustomChart {
     model: CustomModel | null = null;
     private setting: RenderingContextSettings = new RenderingContextSettings(true);
     private context2D: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.setting);
   
     build() {
       Column() {
         Canvas(this.context2D)
           .onReady(() => {
             if (this.model) {
             
               // 画布上下文绑定到图表绘制流程
               this.model.setContext2D(this.context2D);
               
               // 开始绘制图表
               this.model.onDraw(this.context2D);
             }
           })
           .onAreaChange((oldArea: Area, newArea: Area) => {
             if (this.model && ((newArea.width !== oldArea.width) || (newArea.height !== oldArea.height))) {
             
               // 校正图表Size 
               this.model.onChartSizeChanged(Number(newArea.width), Number(newArea.height), Number(oldArea.width), Number(oldArea.height));
             }
           })
           // 绑定手势识别事件
           .priorityGesture(GestureGroup(GestureMode.Parallel,
             TapGesture({ count: 1 })
               .onAction((event?: GestureEvent) => {
                 if (event && this.model) {
                   this.model.onSingleTapUp(false, event);
                 }
               }),
             PanGesture()
               .onActionStart((event?: GestureEvent) => {
                 if (this.model && event) {
                   this.model.onPan(false, 'Down', event);
                 }
               })
               .onActionUpdate((event?: GestureEvent) => {
                 if (this.model && event) {
                   this.model.onPan(false, 'Move', event);
                 }
               })
               .onActionEnd((event?: GestureEvent) => {
                 if (this.model && event) {
                   this.model.onPan(false, 'Up', event);
                 }
               })
           ))
       }
     }
   }
   ```

6. 图表显示

   初始化数据，设置UI显示。

   ```
   aboutToAppear() {
     this.model = new CustomModel();
     // ... 配置各部件样式
     // ... 初始化数据
   }
   
   build() {
     Column() {
       CustomChart({ model: this.model })
         .width('100%')
         .height('100%')
     }
   }
   ```

## 接口说明
**一、ChartModel**

所有图表配置构建类的基类。

| 方法名                     | 描述                                                         |
| -------------------------- | ------------------------------------------------------------ |
| animateX                   | 展示图表时带有X轴动画。                                      |
| animateXY                  | 展示图表时同时带有X轴，Y轴动画。                             |
| animateY                   | 展示图表时带有Y轴动画。                                      |
| calcMinMax                 | 计算 y-min 和 y-max 值以及 y-delta 和 x-delta 值。           |
| calculateOffsets           | 计算图表到边框的偏移量，具体取决于图例的位置，x轴y轴的长度，及其的标签位置。 |
| clear                      | 清空图表的所有数据，将其置空null，并刷新图表。               |
| clearValues                | 从图表中删除所有数据集（以及条目），并刷新图表。             |
| getAnimator                | 返回负责对图表值进行动画处理的动画制作者。                   |
| getCenter                  | 返回图表(整个视图)的中心点的可回收的MPPointF实例。           |
| getCenterOffsets           | 返回图表的图形绘制的中心区域的可回收的MPPointF实例。         |
| getCenterOfView            | 返回图表(整个视图)的中心点的可回收的MPPointF实例。           |
| getContentRect             | 返回图表绘制的内容区域的矩形。                               |
| getData                    | 返回已为图表设置的 ChartData 对象。                          |
| getDefaultValueFormatter   | 返回默认的数据格式化接口实现类。                             |
| getHighlightByTouchPoint   | 返回 LineChart，ScatterChart，CandleStickChart等图表触摸屏幕时的Highlight 对象（包含 x-index 和 DataSet 索引）。 |
| getHighlighted             | 返回当前高亮显示值的数组。这可能是空值，如果没有突出显示，则为空数组。 |
| getHighlighter             | 返回当前高亮显示条目接口。                                   |
| getLegend                  | 获取图例对象，通过该对象的setEnable(false)方法可以关闭图例显示。 |
| getLegendRenderer          | 获取图例渲染器。                                             |
| getRenderer                | 获取图表数据渲染器。                                         |
| getXAxis                   | 获取X轴对象。                                                |
| invalidate                 | 重绘图表。                                                   |
| notifyDataSetChanged       | 图表数据刷新。                                               |
| onChartSizeChanged         | 更新图表正确Size。                                           |
| onDraw                     | 图表绘制方法。                                               |
| setContext2D               | 设置图表绘制的画布。                                         |
| setData                    | 设置图表数据。                                               |
| setDragDecelerationEnabled | 设置是否开启惯性滑动。                                       |
| setHitTestMode             | 设置触摸测试类型。                                           |
| getHitTestMode             | 获取触摸测试类型。                                           |

**1.animateX**

public animateX(durationMillis: number): void;

展示图表时带有X轴动画。

参数：

| 参数名         | 类型   | 必填 | 说明                       |
| -------------- | ------ | ---- | -------------------------- |
| durationMillis | number | 是   | 动画播放的时长，单位毫秒。 |

public animateX(durationMillis: number, easing: string): void;

展示图表时带有X轴动画。

参数：

| 参数名         | 类型   | 必填 | 说明                                                         |
| -------------- | ------ | ---- | ------------------------------------------------------------ |
| durationMillis | number | 是   | 动画播放的时长，单位毫秒。                                   |
| easing         | string | 是   | [动画差值曲线](https://gitee.com/openharmony/docs/blob/master/zh-cn/application-dev/reference/apis/js-apis-animator.md#animatoroptions)。 |

**2.animateXY**

public animateXY(durationMillisX: number, durationMillisY: number): void;

展示图表时同时带有X轴，Y轴动画。

参数：

| 参数名          | 类型   | 必填 | 说明                              |
| --------------- | ------ | ---- | --------------------------------- |
| durationMillisX | number | 是   | X轴条目动画播放的时长，单位毫秒。 |
| durationMillisY | number | 是   | Y轴条目动画播放的时长，单位毫秒。 |

public animateXY(durationMillisX: number, durationMillisY: number, easingX: string): void;

展示图表时同时带有X轴，Y轴动画。

参数：

| 参数名          | 类型   | 必填 | 说明                                                         |
| --------------- | ------ | ---- | ------------------------------------------------------------ |
| durationMillisX | number | 是   | X轴条目动画播放的时长，单位毫秒。                            |
| durationMillisY | number | 是   | Y轴条目动画播放的时长，单位毫秒。                            |
| easingX         | string | 是   | X轴[动画差值曲线](https://gitee.com/openharmony/docs/blob/master/zh-cn/application-dev/reference/apis/js-apis-animator.md#animatoroptions)。 |

public animateXY(durationMillisX: number, durationMillisY: number, easingX: string, easingY: string): void;

展示图表时同时带有X轴，Y轴动画。

参数：

| 参数名          | 类型   | 必填 | 说明                                                         |
| --------------- | ------ | ---- | ------------------------------------------------------------ |
| durationMillisX | number | 是   | X轴条目动画播放的时长，单位毫秒。                            |
| durationMillisY | number | 是   | Y轴条目动画播放的时长，单位毫秒。                            |
| easingX         | string | 是   | X轴[动画差值曲线](https://gitee.com/openharmony/docs/blob/master/zh-cn/application-dev/reference/apis/js-apis-animator.md#animatoroptions)。 |
| easingY         | string | 是   | Y轴[动画差值曲线](https://gitee.com/openharmony/docs/blob/master/zh-cn/application-dev/reference/apis/js-apis-animator.md#animatoroptions)。 |

**3.animateY**

展示图表时带有Y轴动画。

public animateY(durationMillis: number): void;

参数：

| 参数名         | 类型   | 必填 | 说明                       |
| -------------- | ------ | ---- | -------------------------- |
| durationMillis | number | 是   | 动画播放的时长，单位毫秒。 |

public animateY(durationMillis: number, easing: string): void;

参数：

| 参数名         | 类型   | 必填 | 说明                                                         |
| -------------- | ------ | ---- | ------------------------------------------------------------ |
| durationMillis | number | 是   | 动画播放的时长，单位毫秒。                                   |
| easing         | string | 是   | [动画差值曲线](https://gitee.com/openharmony/docs/blob/master/zh-cn/application-dev/reference/apis/js-apis-animator.md#animatoroptions)。 |

**4.calcMinMax**

protected abstract calcMinMax() : void;

计算 y-min 和 y-max 值以及 y-delta 和 x-delta 值。

**5.calculateOffsets**

protected abstract calculateOffsets() : void;

计算图表到边框的偏移量，具体取决于图例的位置，x轴y轴的长度，及其的标签位置。

**6.clear**

public clear() : void;

清空图表的所有数据，将其置空null，并刷新图表。

**7.clearValues**

public clearValues() : void;

从图表中删除所有数据集（以及条目），并刷新图表。

**8.getAnimator**

public getAnimator(): ChartAnimator | null;

返回负责对图表值进行动画处理的动画制作者。

返回值：

| 类型                      | 说明         |
| ------------------------- | ------------ |
| ChartAnimator &#124; null | 动画管理类。 |

**9.getCenter**

public getCenter(): MPPointF;

返回图表(整个视图)的中心点的可回收的MPPointF实例。

返回值：

| 类型     | 说明                   |
| -------- | ---------------------- |
| MPPointF | 可回收的MPPointF实例。 |

**10.getCenterOffsets**

public getCenterOffsets(): MPPointF | null;

返回图表的图形绘制的中心区域的可回收的MPPointF实例。

返回值：

| 类型                 | 说明                   |
| -------------------- | ---------------------- |
| MPPointF &#124; null | 可回收的MPPointF实例。 |

**11.getCenterOfView**

public getCenterOfView(): MPPointF;

返回图表(整个视图)的中心点的可回收的MPPointF实例。

返回值：

| 类型     | 说明                   |
| -------- | ---------------------- |
| MPPointF | 可回收的MPPointF实例。 |

**12.getContentRect**

public getContentRect(): Rect;

返回图表绘制的内容区域的矩形。

返回值：

| 类型 | 说明                       |
| ---- | -------------------------- |
| Rect | 图表绘制的内容区域的矩形。 |

**13.getData**

public getData(): T | null ;

返回已为图表设置的 ChartData 对象。

返回值：

| 类型         | 说明       |
| ------------ | ---------- |
| T&#124; null | 数据对象。 |

**14.getDefaultValueFormatter**

public getDefaultValueFormatter(): IValueFormatter;

返回默认的数据格式化接口实现类。

返回值：

| 类型            | 说明                   |
| --------------- | ---------------------- |
| IValueFormatter | 数据格式化接口实现类。 |

**15.getHighlightByTouchPoint**

public getHighlightByTouchPoint(x: number, y: number): Highlight | null;

返回 LineChart，ScatterChart，CandleStickChart等图表触摸屏幕时的Highlight 对象（包含 x-index 和 DataSet 索引）。

参数：

| 参数名 | 类型   | 必填 | 说明                  |
| ------ | ------ | ---- | --------------------- |
| x      | number | 是   | 屏幕触摸点的x轴坐标。 |
| y      | number | 是   | 屏幕触摸点的y轴坐标。 |

返回值：

| 类型                  | 说明               |
| --------------------- | ------------------ |
| Highlight &#124; null | 触摸点的高亮对象。 |

**16.getHighlighted**

public getHighlighted(): Highlight[] | null;

返回当前高亮显示值的数组。这可能是空值，如果没有突出显示，则为空数组。

参数：

| 参数名 | 类型   | 必填 | 说明                  |
| ------ | ------ | ---- | --------------------- |
| x      | number | 是   | 屏幕触摸点的x轴坐标。 |
| y      | number | 是   | 屏幕触摸点的y轴坐标。 |

返回值：

| 类型                  | 说明               |
| --------------------- | ------------------ |
| Highlight &#124; null | 触摸点的高亮对象。 |

**17.getHighlighter**

public getHighlighter(): IHighlighter | null;

返回当前高亮显示条目接口。

返回值：

| 类型                     | 说明                         |
| ------------------------ | ---------------------------- |
| IHighlighter &#124; null | 获取触摸点的高亮对象接口类。 |

**18.getLegend**

public getLegend(): Legend | null ;

获取图例对象。

返回值：

| 类型               | 说明           |
| ------------------ | -------------- |
| Legend &#124; null | 获取图例对象。 |

**19.getLegendRenderer**

public getLegendRenderer(): LegendRenderer | null;

获取图例渲染器。

返回值：

| 类型                      | 说明             |
| ------------------------- | ---------------- |
| LegendRenderer&#124; null | 获取图例渲染器。 |

**20.getRenderer**

public getRenderer(): DataRenderer | null;

获取图表数据渲染器。

返回值：

| 类型                     | 说明                 |
| ------------------------ | -------------------- |
| DataRenderer &#124; null | 获取图表数据渲染器。 |

**21.getXAxis**

public getXAxis(): XAxis | null;

获取X轴对象。

返回值：

| 类型              | 说明          |
| ----------------- | ------------- |
| XAxis &#124; null | 获取X轴对象。 |


**22.invalidate**

public abstract invalidate();

重绘图表。

**23.notifyDataSetChanged**

public abstract notifyDataSetChanged();

图表数据刷新。

**24.onChartSizeChanged**

public abstract onChartSizeChanged(newWidth: number, newHeight: number, oldWidth: number, oldHeight: number): void;

更新图表正确Size。

参数：

| 参数名    | 类型   | 必填 | 说明                     |
| --------- | ------ | ---- | ------------------------ |
| newWidth  | number | 是   | 图表当前显示的宽。       |
| newHeight | number | 是   | 图表当前显示的高。       |
| oldWidth  | number | 是   | 图表改变Size前显示的宽。 |
| oldHeight | number | 是   | 图表改变Size前显示的高。 |

**25.onDraw**

protected onDraw(c: CanvasRenderingContext2D): void ;

图表绘制方法。

参数：

| 参数名 | 类型                     | 必填 | 说明       |
| ------ | ------------------------ | ---- |----------|
| c      | CanvasRenderingContext2D | 是   | 图表绘制的画布。 |

**26.setContext2D**

public abstract setContext2D(context2d: CanvasRenderingContext2D);

设置图表绘制的画布。

参数：

| 参数名 | 类型                     | 必填 | 说明       |
| ------ | ------------------------ | ---- |----------|
| c      | CanvasRenderingContext2D | 是   | 图表绘制的画布。 |

**27.setData**

public setData(data: T) : void;

设置图表数据。

参数：

| 参数名 | 类型 | 必填 | 说明                         |
| ------ | ---- | ---- | ---------------------------- |
| data   | T    | 是   | 图表数据，T继承自ChartData。 |

**28.setDragDecelerationEnabled**

public setDragDecelerationEnabled(enabled: boolean);

设置是否开启惯性滑动

参数：

| 参数名 | 类型 | 必填 | 说明                 |
| ------ | ---- | ---- |--------------------|
| enabled   | boolean    | 是   | 能力标识。 |

**29.setHitTestMode**

public setHitTestMode(hitTestMode: HitTestMode)

设置触摸测试类型

参数：

| 参数名 | 类型 | 必填 | 说明                 |
| ------ | ---- | ---- |--------------------|
| hitTestMode   | HitTestMode    | 是   | 触摸测试类型 |

**30.getHitTestMode**

public getHitTestMode(): HitTestMode

获取触摸测试类型。

返回值：

| 类型    | 说明        |
|-------| ----------- |
| HitTestMode | 触摸测试类型 |

**二、BarLineChartBaseModel**

柱状图基础类

| 方法名                    | 描述                                               |
| ------------------------- | -------------------------------------------------- |
| calcMinMax                | 计算坐标的最大最小值。                             |
| calculateOffsets          | 计算图表offset。                                   |
| drawGridBackground        | 绘制图表背景。                                     |
| getAxis                   | 根据Y轴位置获取Y轴对象。                           |
| getAxisLeft               | 获取左Y轴对象。                                    |
| getAxisRight              | 获取右Y轴对象。                                    |
| getMinOffset              | 获取最小Offset值。                                 |
| getRendererLeftYAxis      | 获取左Y轴渲染器。                                  |
| getRendererRightYAxis     | 获取右Y轴渲染器。                                  |
| getRendererXAxis          | 获取X轴渲染器。                                    |
| setLongPressCursorEnabled | 设置长按游标能力标识。                             |
| getLongPressCursorEnabled | 获取长按游标能力标识。                             |
| setLongPressDuration      | 设置长按响应时长。                                 |
| getLongPressDuration      | 获取长按响应时长。                                 |
| setSwipeEnabled           | 设置手势滑动响应能力（结合长按游标能力使用）。     |
| getSwipeEnabled           | 获取手势滑动响应能力标识（结合长按游标能力使用）。 |

**1.calcMinMax**

protected calcMinMax(): void;

计算坐标的最大最小值。

**2.calculateOffsets**

public calculateOffsets(): void;

计算图表offset。

**3.drawGridBackground**

protected drawGridBackground(c: CanvasRenderingContext2D): void;

绘制图表背景。

参数：

| 参数名 | 类型                     | 必填 | 说明               |
| ------ | ------------------------ | ---- | ------------------ |
| c      | CanvasRenderingContext2D | 是   | 图表绘制的上下文。 |

**4.getAxis**

public getAxis(axis: AxisDependency): YAxis | null;

根据Y轴位置获取Y轴对象。

参数：

| 参数名 | 类型           | 必填 | 说明      |
| ------ | -------------- | ---- | --------- |
| axis   | AxisDependency | 是   | Y轴位置。 |

返回值：

| 类型              | 说明          |
| ----------------- | ------------- |
| YAxis &#124; null | 获取Y轴对象。 |

**5.getAxisLeft**

public getAxisLeft(): YAxis | null;

获取左Y轴对象。

返回值：

| 类型              | 说明          |
| ----------------- | ------------- |
| YAxis &#124; null | 获取Y轴对象。 |

**6.getAxisRight**

public getAxisRight(): YAxis | null;

获取右Y轴对象。

返回值：

| 类型              | 说明          |
| ----------------- | ------------- |
| YAxis &#124; null | 获取Y轴对象。 |

**7.getMinOffset**

public getMinOffset(): number;

获取最小Offset值。

返回值：

| 类型   | 说明               |
| ------ | ------------------ |
| number | 获取最小Offset值。 |

**8.getRendererLeftYAxis**

public getRendererLeftYAxis(): YAxisRenderer | null;

获取左Y轴渲染器。

返回值：

| 类型                      | 说明              |
| ------------------------- | ----------------- |
| YAxisRenderer &#124; null | 获取左Y轴渲染器。 |

**9.getRendererRightYAxis**

public getRendererRightYAxis(): YAxisRenderer | null;

获取右Y轴渲染器。

返回值：

| 类型                      | 说明              |
| ------------------------- | ----------------- |
| YAxisRenderer &#124; null | 获取右Y轴渲染器。 |

**10.getRendererXAxis**

public getRendererXAxis(): XAxisRenderer | null;

获取X轴渲染器。

返回值：

| 类型                      | 说明            |
| ------------------------- | --------------- |
| XAxisRenderer &#124; null | 获取X轴渲染器。 |

**11.setLongPressCursorEnabled**

public setLongPressCursorEnabled(enabled: boolean): void;

设置长按游标能力标识。

参数：

| 参数名 | 类型      | 必填 | 说明    |
| ------ |---------| ---- |-------|
| enabled   | boolean | 是   | 能力标识。 |

返回值：无

**12.getLongPressCursorEnabled**

public getLongPressCursorEnabled(): boolean;

获取长按游标能力标识。

参数：无

返回值：

| 类型      | 说明        |
|---------|-----------|
| boolean | 长按游标能力标识。 |

**13.setLongPressDuration**

public setLongPressDuration(duration: number): void;

设置长按响应时长。

参数：

| 参数名 | 类型      | 必填 | 说明  |
| ------ |---------| ---- |-----|
| duration   | number | 是   | 时长。 |

返回值：无

**14.getLongPressDuration**

public getLongPressDuration(): number;

获取长按响应时长。

参数：无

返回值：

| 类型      | 说明    |
|---------|-------|
| number | 响应时长。 |

**15.setSwipeEnabled**

public setSwipeEnabled(enabled: boolean): void;

设置手势滑动响应能力（结合长按游标能力使用）。

参数：

| 参数名 | 类型      | 必填 | 说明    |
| ------ |---------| ---- |-------|
| enabled   | boolean | 是   | 能力标识。 |

返回值：无

**16.getSwipeEnabled**

public getSwipeEnabled(): boolean;

获取手势滑动响应能力标识（结合长按游标能力使用）。

参数：无

返回值：

| 类型      | 说明        |
|---------|-----------|
| boolean | 手势滑动响应能力标识。 |

**三、ComponentBase**

图表部件基础类。

| 方法名       | 描述                                 |
| ------------ | ------------------------------------ |
| setTextColor | 设置部件文本渲染颜色。               |
| getTextColor | 获取部件文本渲染颜色。               |
| setTextSize  | 设置部件文本Size，需要转化为vp单位。 |
| getTextSize  | 获取部件文本Size。                   |
| setXOffset   | 设置X轴距离图表内容区域的Offset。    |
| getXOffset   | 获取X轴距离图表内容区域的Offset。    |
| setYOffset   | 设置Y轴距离图表内容区域的Offset。    |
| getYOffset   | 获取Y轴距离图表内容区域的Offset。    |

**1.setTextColor**

public setTextColor(color: string | number | CanvasGradient | CanvasPattern): void;

设置部件文本渲染颜色。

参数：

| 参数名 | 类型                                                        | 必填 | 说明                   |
| ------ | ----------------------------------------------------------- | ---- | ---------------------- |
| color  | string &#124;number&#124;CanvasGradient &#124;CanvasPattern | 是   | 设置部件文本渲染颜色。 |

**2.getTextColor**

public getTextColor(): string | number | CanvasGradient | CanvasPattern;

获取部件文本渲染颜色。

返回值：

| 类型                                                        | 说明                   |
| ----------------------------------------------------------- | ---------------------- |
| string &#124;number&#124;CanvasGradient &#124;CanvasPattern | 获取部件文本渲染颜色。 |

**3.setTextSize**

public setTextSize(size: number): void;

设置部件文本Size，单位是vp。

参数：

| 参数名 | 类型   | 必填 | 说明               |
| ------ | ------ | ---- | ------------------ |
| size   | number | 是   | 设置部件文本Size。 |

**4.getTextSize**

public getTextSize(): number;

获取部件文本Size。

返回值：

| 类型   | 说明               |
| ------ | ------------------ |
| number | 获取部件文本Size。 |

**5.setXOffset**

public setXOffset(xOffset: number): void;

设置X轴距离图表内容区域的Offset。

参数：

| 参数名  | 类型   | 必填 | 说明                              |
| ------- | ------ | ---- | --------------------------------- |
| xOffset | number | 是   | 设置X轴距离图表内容区域的Offset。 |

**6.getXOffset**

public getXOffset(): number;

获取X轴距离图表内容区域的Offset。

返回值：

| 类型   | 说明                              |
| ------ | --------------------------------- |
| number | 获取X轴距离图表内容区域的Offset。 |

**7.setYOffset**

public setYOffset(yOffset: number): void;

设置Y轴距离图表内容区域的Offset。

参数：

| 参数名  | 类型   | 必填 | 说明                              |
| ------- | ------ | ---- | --------------------------------- |
| yOffset | number | 是   | 设置Y轴距离图表内容区域的Offset。 |

**8.getYOffset**

public getYOffset(): number;

获取Y轴距离图表内容区域的Offset。

返回值：

| 类型   | 说明                              |
| ------ | --------------------------------- |
| number | 获取Y轴距离图表内容区域的Offset。 |

**四、AxisBase**

坐标轴基类。

| 方法名                      | 描述                                               |
| --------------------------- | -------------------------------------------------- |
| addLimitLine                | 为坐标轴添加限制线对象。                           |
| calculate                   | 计算预期坐标轴的最大最小值，用于自定义坐标轴使用。 |
| setAxisMaximum              | 设置自定义的轴的最大值。                           |
| setAxisMinimum              | 设置自定义的轴的最小值。                           |
| setDrawAxisLine             | 设置是否绘制轴线。                                 |
| setDrawGridLines            | 设置是否绘制网格线。                               |
| setDrawGridLinesBehindData  | 设置是否在数据后绘制网格线。                       |
| setDrawLimitLinesBehindData | 设置是否在数据后绘制限制线。                       |
| setValueFormatter           | 设置数据的格式转换器。                             |

**1.addLimitLine**

public addLimitLine(limitLine: LimitLine): void;

为坐标轴添加限制线对象。

参数：

| 参数名    | 类型      | 必填 | 说明                     |
| --------- | --------- | ---- | ------------------------ |
| limitLine | LimitLine | 是   | 为坐标轴添加限制线对象。 |

**2.calculate**

public calculate(dataMin: number, dataMax: number): void;

计算预期坐标轴的最大最小值，用于自定义坐标轴使用。

参数：

| 参数名  | 类型   | 必填 | 说明                 |
| ------- | ------ | ---- | -------------------- |
| dataMin | number | 是   | 数据集合中的最小值。 |
| dataMax | number | 是   | 数据集合中的最大值。 |

**3.setAxisMaximum**

public setAxisMaximum(max: number): void;

设置自定义的轴的最大值。

参数：

| 参数名 | 类型   | 必填 | 说明               |
| ------ | ------ | ---- | ------------------ |
| max    | number | 是   | 自定义的轴最大值。 |

**4.setAxisMinimum**

public setAxisMinimum(min: number): void;

设置自定义的轴的最小值。

参数：

| 参数名 | 类型   | 必填 | 说明                 |
| ------ | ------ | ---- | -------------------- |
| min    | number | 是   | 自定义的轴的最小值。 |

**5.setDrawAxisLine**

public setDrawAxisLine(enabled: boolean): void;

设置是否绘制轴线。

参数：

| 参数名  | 类型    | 必填 | 说明               |
| ------- | ------- | ---- | ------------------ |
| enabled | boolean | 是   | 设置是否绘制轴线。 |

**6.setDrawGridLines**

public setDrawGridLines(enabled: boolean): void;

设置是否绘制网格线。

参数：

| 参数名  | 类型    | 必填 | 说明                 |
| ------- | ------- | ---- | -------------------- |
| enabled | boolean | 是   | 设置是否绘制网格线。 |

**7.setDrawGridLinesBehindData**

public setDrawGridLinesBehindData(enabled: boolean): void;

设置是否在数据后绘制网格线。

参数：

| 参数名  | 类型    | 必填 | 说明                         |
| ------- | ------- | ---- | ---------------------------- |
| enabled | boolean | 是   | 设置是否在数据后绘制网格线。 |

**8.setDrawLimitLinesBehindData**

public setDrawLimitLinesBehindData(enabled: boolean): void ;

设置是否在数据后绘制限制线。

参数：

| 参数名  | 类型    | 必填 | 说明                         |
| ------- | ------- | ---- | ---------------------------- |
| enabled | boolean | 是   | 设置是否在数据后绘制限制线。 |

**9.setValueFormatter**

public setValueFormatter(formatter: IAxisValueFormatter): void ;

设置数据的格式转换器。

参数：

| 参数名    | 类型                | 必填 | 说明                   |
| --------- | ------------------- | ---- | ---------------------- |
| formatter | IAxisValueFormatter | 是   | 设置数据的格式转换器。 |

**五、XAxis**

X轴对象。

| 方法名                | 描述                           |
| --------------------- | ------------------------------ |
| setPosition           | 设置X轴显示位置。              |
| getPosition           | 获取X轴显示位置。              |
| setLabelRotationAngle | 设置X轴标签旋转角度。          |
| getLabelRotationAngle | 获取X轴标签旋转角度。          |
| setLabelXOffset       | 获取X轴标签偏移量。            |
| getLabelXOffset       | 获取标签在 X 轴上的偏移量。    |
| setXAxisLabelPosition | 设置X轴标签位置。              |
| getXAxisLabelPosition | 获取X轴标签位置。              |
| setCustomLabels       | 设置x轴自定义Labels。          |
| getCustomLabels       | 获取自定义Labels。             |
| setDrawCustomLabels   | 设置是否使用自定义Labels。     |
| isDrawCustomLabels    | 检查是否正在使用自定义Labels。 |

**1.setPosition**

public setPosition(pos: XAxisPosition): void;

设置X轴显示位置。

参数：

| 参数名 | 类型          | 必填 | 说明              |
| ------ | ------------- | ---- | ----------------- |
| pos    | XAxisPosition | 是   | 设置X轴显示位置。 |

**2.getPosition**

public getPosition(): XAxisPosition;

获取X轴显示位置。

返回值：

| 类型          | 说明              |
| ------------- | ----------------- |
| XAxisPosition | 获取X轴显示位置。 |

**3.setLabelRotationAngle**

public setLabelRotationAngle(angle: number): void;

设置X轴标签旋转角度。

参数：

| 参数名 | 类型   | 必填 | 说明                  |
| ------ | ------ | ---- | --------------------- |
| angle  | number | 是   | 设置X轴标签旋转角度。 |

**4.getLabelRotationAngle**

public getLabelRotationAngle(): number;

获取X轴标签旋转角度。

返回值：

| 类型   | 说明                  |
| ------ | --------------------- |
| number | 获取X轴标签旋转角度。 |

**5.setLabelXOffset**

public setLabelXOffset(xOffset: number): void

获取X轴标签偏移量

返回值：无

参数：

| 参数名 | 类型   | 必填 | 说明         |
| ------ | ------ | ---- |------------|
| xOffset  | number | 是   | 设置X轴标签偏移量。 |

**6.getLabelXOffset**

public getLabelXOffset(): number

获取标签在 X 轴上的偏移量

返回值：

| 类型   | 说明                  |
| ------ | --------------------- |
| number | 获取标签在 X 轴上的偏移量。 |

参数：无

**7.setXAxisLabelPosition**

public setXAxisLabelPosition(position: XAxisLabelPosition): void

设置X轴标签位置

返回值：无

参数：

| 参数名 | 类型   | 必填 | 说明         |
| ------ | ------ | ---- |------------|
| position  | XAxisLabelPosition | 是   | 设置X轴标签位置 |

**8.getXAxisLabelPosition**

public getXAxisLabelPosition(): XAxisLabelPosition

获取X轴标签位置

返回值：

| 类型   | 说明                  |
| ------ | --------------------- |
| XAxisLabelPosition | X轴标签位置 |

参数：无


**9.setCustomLabels**

public setCustomLabels(numbers: number[]): void

设置x轴自定义Labels

返回值：无

参数：

| 参数名 | 类型   | 必填 | 说明         |
| ------ | ------ | ---- |------------|
| numbers  | number[] | 是   | 设置x轴自定义Labels |

**10.getCustomLabels**

public getCustomLabels(): number[]

获取自定义Labels

返回值：

| 类型   | 说明                  |
| ------ | --------------------- |
| number[] | 自定义Labels |

参数：无

**11.setDrawCustomLabels**

public setDrawCustomLabels(flag: boolean): void

设置是否使用自定义Labels

返回值：无

参数：

| 参数名 | 类型      | 必填 | 说明         |
| ------ |---------| ---- |------------|
| flag  | boolean | 是   | 设置是否使用自定义Labels |

**12.isDrawCustomLabels**

public isDrawCustomLabels(): boolean

检查是否正在使用自定义Labels

返回值：

| 类型   | 说明                  |
| ------ | --------------------- |
| boolean | 是否正在使用自定义Labels |

参数：无


**六、YAxis**

Y轴对象。

| 方法名                | 描述                                                         |
| --------------------- | ------------------------------------------------------------ |
| calculate             | 计算轴上的预期的最大最小值。                                 |
| getAxisDependency     | 获取Y轴位置。                                                |
| setPosition           | 设置Y轴标签的位置。                                          |
| getLabelPosition      | 获取Y轴标签的位置。                                          |
| setLabelXOffset       | 设置Y轴标签的X轴方向上的Offset。                             |
| getLabelXOffset       | 获取Y轴标签的X轴方向上的Offset。                             |
| setDrawZeroLine       | 设置是否绘制0线。                                            |
| EventControl          | 事件控制类，EventType 为枚举类型(单击、双击、长按)           |
| setEventEnable        | 启用事件。                                                   |
| setEventDisable       | 禁用事件。                                                   |
| eventIsEnable         | 事件是否启用。                                               |
| eventIsDisable        | 事件是否被禁用。                                             |
| setYAxisExtensionLine | 设置y轴延伸线。                                              |
| addGridLine           | 添加自定义网格线。                                           |
| getGridLines          | 获取自定义网格线。                                           |
| setGridAlpha          | 设置网格线颜色不透明度（不包含addGridLine添加的自定义网格线，自定义网格线可通过color属性传入带透明度的颜色） |

**1.calculate**

public calculate(dataMin: number, dataMax: number): void;

计算轴上的预期的最大最小值。

参数：

| 参数名  | 类型   | 必填 | 说明                  |
| ------- | ------ | ---- | --------------------- |
| dataMin | number | 是   | 数据集合中的Y最小值。 |
| dataMax | number | 是   | 数据集合中的Y最大值   |

**2.getAxisDependency**

public getAxisDependency(): AxisDependency;

获取Y轴位置。

返回值：

| 类型   | 说明          |
| ------ | ------------- |
| number | 获取Y轴位置。 |

**3.setPosition**

public setPosition(pos: YAxisLabelPosition): void;

设置Y轴标签的位置。

参数：

| 参数名 | 类型               | 必填 | 说明                |
| ------ | ------------------ | ---- | ------------------- |
| pos    | YAxisLabelPosition | 是   | 设置Y轴标签的位置。 |

**4.getLabelPosition**

public getLabelPosition(): YAxisLabelPosition;

获取Y轴标签的位置。

返回值：

| 类型               | 说明              |
| ------------------ | ----------------- |
| YAxisLabelPosition | 获取Y轴标签位置。 |

**5.setLabelXOffset**

public setLabelXOffset(xOffset: number): void;

设置Y轴标签的X轴方向上的Offset。

参数：

| 参数名  | 类型   | 必填 | 说明                             |
| ------- | ------ | ---- | -------------------------------- |
| xOffset | number | 是   | 设置Y轴标签的X轴方向上的Offset。 |

**6.getLabelXOffset**

public getLabelXOffset(): number;

获取Y轴标签的X轴方向上的Offset。

返回值：

| 类型   | 说明                             |
| ------ | -------------------------------- |
| number | 获取Y轴标签的X轴方向上的Offset。 |

**7.setDrawZeroLine**

public setDrawZeroLine(mDrawZeroLine: boolean): void;

设置是否绘制0线。

参数：

| 参数名        | 类型    | 必填 | 说明          |
| ------------- | ------- | ---- | ------------- |
| mDrawZeroLine | boolean | 是   | 是否绘制0线。 |

**8.EventControl事件控制类**

EventType 为枚举类型(单击、双击、长按)

enum EventType {
SingleTap,
DoubleTap,
LongPress
}

**9.setEventEnable**

public setEventEnable(evType: EventType): EventControl

启用事件

参数：

| 参数名 | 类型               | 必填 | 说明                                |
| ------ | ------------------ | ---- |-----------------------------------|
| evType    | EventType | 是   | SingleTap、DoubleTap、LongPress三个选项 |

**10.setEventDisable**

public setEventDisable(evType: EventType): EventControl

禁用事件

参数：

| 参数名 | 类型               | 必填 | 说明                                |
| ------ | ------------------ | ---- |-----------------------------------|
| evType    | EventType | 是   | SingleTap、DoubleTap、LongPress三个选项 |

**11.eventIsEnable**

public eventIsEnable(evType: EventType): boolean; 

事件是否启用。

参数：

| 参数名 | 类型               | 必填 | 说明                                |
| ------ | ------------------ | ---- |-----------------------------------|
| evType    | EventType | 是   | SingleTap、DoubleTap、LongPress三个选项 |

**12.eventIsDisable** 

public eventIsDisable(evType: EventType): boolean;

事件是否被禁用。

参数：

| 参数名 | 类型               | 必填 | 说明                                 |
| ------ | ------------------ | ---- |------------------------------------|
| evType    | EventType | 是   | SingleTap、DoubleTap、LongPress三个选项  |

**13.setYAxisExtensionLine**

public setYAxisExtensionLine(opt: boolean): void

设置y轴延伸线。

参数：

| 参数名 | 类型      | 必填 | 说明         |
|-----|---------| ---- |------------|
| opt | boolean | 是   | 是否绘制y轴延伸线。 |

**14.addGridLine**

public addGridLine(customLine: GridLineConfig): void

添加自定义网格线。

参数：

| 参数名 | 类型      | 必填 | 说明       |
|-----|---------| ---- |----------|
| customLine | GridLineConfig | 是   | 设置网格线样式。 |

**15.getGridLines**

public getGridLines(): JArrayList<LimitLine>

获取自定义网格线。

返回值：

| 类型                    | 说明       |
|-----------------------|----------|
| JArrayList<LimitLine> | 自定义网格线数组 |

**16.setGridAlpha**

public setGridAlpha(alpha: number): void

设置网格线颜色不透明度（不包含addGridLine添加的自定义网格线，自定义网格线可通过color属性传入带透明度的颜色）

参数：

| 参数名   | 类型     | 必填  | 说明                                     |
|-------|--------|-----|----------------------------------------|
| alpha | number | 是   | 设置网格线颜色不透明度,取值0到255之间，0是完全透明，255是完全不透明 |

```
// 示例代码参见 CustomGridLineChartPage
export interface GridLineConfig {
   position: number;
   lineWidth?: number;
   lineColor?: number;
   dashPathEffect?: DashPathEffectConfig
}

export interface DashPathEffectConfig {
   lineLength: number;
   spaceLength: number;
   phase: number
}
```

**六、自定义MarkerView传入**

```typescript

@State customUiInfo: CustomUiInfo = new CustomUiInfo(90, 50);
        
@Builder customUi() {
   // 是否在图表content内
   if (this.customUiInfo.isInbounds && this.customUiInfo.data) {
      Column() {
        Text(`2023-12-15`).fontColor(Color.Gray).fontSize(12).fontWeight(FontWeight.Bold)
        Text(`X: ${this.customUiInfo.data.getX()}`).fontColor(Color.Gray).fontSize(12)
        Text(`Y: ${this.customUiInfo.data.getY()}`).fontColor(Color.Gray).fontSize(12)
      }
   .padding(4)
      .borderRadius(6)
      .border({ width: 1, color: Color.Orange})
      .backgroundColor(0xf0f0f0)
      .width(this.customUiInfo.width)
      .height(this.customUiInfo.height)
      .margin({ left: this.customUiInfo.x, top: this.customUiInfo.y })
      .alignItems(HorizontalAlign.Start)
      .onClick(ev => {
         this.customUiInfo.showUi = false;
      })
   }
}


BarChart({ model: this.model,
   // 自定义 ui: 传入 builder
   customUiBuilder: this.customUi,
   // 通过什么事件触发
   customUiTriggerEvent: EventType.SingleTap,
   // 自定义ui的位置信息
   customUiInfo: this.customUiInfo,
})
```
**七、WaterfallDataSet**

瀑布图数据类

| 方法名        | 描述                         |
| ------------- | ---------------------------- |
| setDotsColors | 瀑布图设置所有高亮点的颜色。 |
| getDotsColors | 获取瀑布图所有高亮点的颜色。 |

**1.setDotsColors**

public setDotsColors(color: number | string): void;

瀑布图设置所有高亮点的颜色。

参数：

| 参数名 | 类型                   | 必填 | 说明                       |
| ------ |----------------------| ---- |--------------------------|
| color  | number &#124; string | 是   | 要设置的颜色，可以是number或string。 |

**2.getDotsColors**

public getDotsColors(): Array<string | number> {

获取瀑布图所有高亮点的颜色。

返回值：

| 类型                          | 说明                        |
|-----------------------------| --------------------------- |
| Array<string &#124; number> | 返回包含所有高亮点颜色的数组。 |

**八、ChartData**

图表数据类

| 方法名                  | 描述                                    |
| ----------------------- | --------------------------------------- |
| setHighlightByXDistance | 设置是否仅通过X轴距离来判断是否高亮点。 |
| isHighlightByXDistance  | 检查是否仅通过X轴距离来判断是否高亮点。 |

**1.setHighlightByXDistance**

public setHighlightByXDistance(highlightByXDistance: boolean): void;

设置是否仅通过X轴距离来判断是否高亮点。

参数：

| 参数名 | 类型      | 必填 | 说明                       |
| ------ |---------| ---- |--------------------------|
| highlightByXDistance  | boolean | 是   | 是否仅通过X轴距离来判断是否高亮点 |

**2.isHighlightByXDistance**

public isHighlightByXDistance(): boolean

检查是否仅通过X轴距离来判断是否高亮点。

返回值：

| 类型      | 说明     |
|---------|--------|
| boolean | 是否仅通过X轴距离来判断是否高亮点的布尔值 |

**九、BarLineScatterCandleBubbleDataSet**

Bar,Line,Scatter,Candle,Bubble五种图表数据的抽象基类

**1.setHighLightColor**

public setHighLightColor(color: number): void;

设置用于绘制高亮指示器的颜色。

参数：

| 参数名 | 类型   | 必填 | 说明             |
| ------ | ------ | ---- | ---------------- |
| color  | number | 是   | 高亮指示器的颜色 |

**2.getHighLightColor**

public getHighLightColor(): number;

获取用于绘制高亮指示器的颜色。

返回值：

| 类型   | 说明             |
| ------ | ---------------- |
| number | 高亮指示器的颜色 |

**3.copyTo**

protected copyTo(barLineScatterCandleBubbleDataSet: BarLineScatterCandleBubbleDataSet<T>): void

复制数据到指定的dataSet

参数：

| 参数名                            | 类型                                 | 必填 | 说明                    |
| --------------------------------- | ------------------------------------ | ---- | ----------------------- |
| barLineScatterCandleBubbleDataSet | BarLineScatterCandleBubbleDataSet<T> | 是   | 复制数据到指定的dataSet |

**十、LineScatterCandleRadarDataSet**

**1.setDrawHorizontalHighlightIndicator**

public setDrawHorizontalHighlightIndicator(enabled: boolean): void;

设置启用/禁用水平突出显示指示器。

参数：

| 参数名  | 类型    | 必填 | 说明                                                    |
| ------- | ------- | ---- | ------------------------------------------------------- |
| enabled | boolean | 是   | 启用/禁用水平突出显示指示器。如果禁用，则不绘制指示器。 |

**2.setDrawVerticalHighlightIndicator**

public setDrawVerticalHighlightIndicator(enabled: boolean): void;

设置启用/禁用垂直突出显示指示器。

参数：

| 参数名  | 类型    | 必填 | 说明                                                    |
| ------- | ------- | ---- | ------------------------------------------------------- |
| enabled | boolean | 是   | 启用/禁用垂直突出显示指示器。如果禁用，则不绘制指示器。 |

**3.setDrawHighlightIndicators**

public setDrawHighlightIndicators(enabled: boolean): void;

设置启用/禁用水平和垂直突出显示指示器。

参数：

| 参数名  | 类型    | 必填 | 说明                                |
| ------- | ------- | ---- | ----------------------------------- |
| enabled | boolean | 是   | 启用/禁用水平和垂直突出显示指示器。 |



**4.isVerticalHighlightIndicatorEnabled**

public isVerticalHighlightIndicatorEnabled(): boolean;

获取是否启用垂直突出显示指示器。

返回值：

| 类型    | 说明                         |
| ------- | ---------------------------- |
| boolean | 是否启用垂直突出显示指示器。 |

**5.isHorizontalHighlightIndicatorEnabled**

public isVerticalHighlightIndicatorEnabled(): boolean;

获取是否启用水平突出显示指示器。

返回值：

| 类型    | 说明                         |
| ------- | ---------------------------- |
| boolean | 是否启用水平突出显示指示器。 |

**6.setHighlightLineWidth**

public setHighlightLineWidth(width: number): void;

设置高亮线的宽度，单位是vp。

参数：

| 参数名 | 类型   | 必填 | 说明                         |
| ------ | ------ | ---- | ---------------------------- |
| width  | number | 是   | 设置高亮线的宽度，单位是vp。 |

**7.getHighlightLineWidth**

public getHighlightLineWidth(): number;

获取高亮线的宽度。

返回值：

| 类型   | 说明           |
| ------ | -------------- |
| number | 高亮线的宽度。 |

**8.enableDashedHighlightLine**

public enableDashedHighlightLine(lineLength: number, spaceLength: number, phase: number): void;

允许以虚线模式绘制高亮线，例如“------”。

参数：

| 参数名      | 类型   | 必填 | 说明                              |
| ----------- | ------ | ---- | --------------------------------- |
| lineLength  | number | 是   | 线段的长度。                      |
| spaceLength | number | 是   | 空隙的长度。                      |
| phase       | number | 是   | 相位偏移，单位为度（通常使用0）。 |

**9.disableDashedHighlightLine**

public disableDashedHighlightLine(): void;

禁用以虚线模式绘制的高亮线。

无返回值

**10.isDashedHighlightLineEnabled**

public isDashedHighlightLineEnabled(): boolean;

如果高亮线启用了虚线效果，则返回true，否则返回false。

返回值：

| 类型    | 说明                     |
| ------- | ------------------------ |
| boolean | 高亮线是否启用了虚线效果 |

**11.getDashPathEffectHighlight**

public getDashPathEffectHighlight(): DashPathEffect;

获取虚线效果。

返回值：

| 类型           | 说明     |
| -------------- | -------- |
| DashPathEffect | 虚线效果 |

**12.copyTo**

protected copyTo(lineScatterCandleRadarDataSet: LineScatterCandleRadarDataSet<T>): void；

拷贝数据至指定dataset。

参数：

| 参数名                        | 类型                          | 必填 | 说明        |
| ----------------------------- | ----------------------------- | ---- | ----------- |
| lineScatterCandleRadarDataSet | LineScatterCandleRadarDataSet | 是   | dataset数据 |

## 常见问题

**1.如果去除图例?**

```typescript
this.model.getLegend()?.setEnabled(false);
```

**2.如果去除右下角Description字样？**

```typescript
this.model.getDescription()?.setEnabled(false);
```

**3 . 如何隐藏 Y 轴线？**

```kotlin
this.model.getAxisLeft().setEnabled(false) //隐藏左边Y轴轴线，此时标签数字也隐藏
```

**4.如果想隐藏轴线但是想显示数字标签？**

```typescript
this.model.getAxisRight().setDrawAxisLine(false);
```

**5.如何控制 Y 轴线数据标签个数?**

```typescript
this.model.getAxisLeft().setLabelCount(8, false);//设置了8个
```

**6.如何设置轴线颜色，宽度等信息?**

```typescript
let leftAxis = this.model.getAxisLeft();
leftAxis.setPosition(YAxisLabelPosition.OUTSIDE_CHART);//显示轴线在图表内部则使用INSIDE_CHART
this.leftAxis.setAxisLineColor(ColorTemplate.rgb("#ff0000"));//设置轴线颜色
leftAxis.setAxisLineWidth(1);// 设置轴线宽度
leftAxis.setTextSize(20);//设置y轴标签字体大小
leftAxis.setDrawGridLines(true);//设置显示网格线
```

**7.如何自定义坐标轴标签?**

如果不想用坐标轴本身的阿拉伯数字标签，也可以自定义坐标轴标签，实现方法是通过创建自定义类实现 IAxisValueFormatter 接口，修改其中的 getFormattedValue 方法，最后调用坐标轴对象的 setValueFormatter 方法就可以实现自定义坐标轴标签。

```typescript
class MyAxisValueFormatter implements IAxisValueFormatter {
  getFormattedValue(value: number, axis: AxisBase): string {
    //将原本存在的对应的value转换成需要的字符串
    switch (value) {
      case 1:
        return "一";
      case 2:
        return "二";
      case 3:
        return "三";
    }
    return '';
  }
}
...
this.topAxis.setValueFormatter(new TopAxisValueFormatter())
```

**8.图表的缩放、触摸等交互设置如何关闭或打开？**

● setTouchEnabled( enabled: boolean): 允许打开或者关闭与图表的所有触摸交互的情况。
● setDragEnabled( enabled: boolean): 打开或关闭对图表的拖动。
● setScaleEnabled(enabled: boolean):打开或关闭对图表所有方向的缩放。
● setScaleXEnabled(enabled: boolean): 打开或关闭x轴方向上的缩放
● setScaleYEnabled(enabled: boolean): 打开或关闭y轴方向上的缩放。
● setPinchZoom(enabled: boolean): 如果设置为true，手势捏合缩放被打开。如果设置为false，x和y轴可以被手势捏合缩放。
● setHighlightPerTapEnabled(enabled: boolean): 如果设置为true，在图表中选中触发高亮效果。
● setHighlightPerDragEnabled(enabled: boolean): 设置为true时允许在手指滑动结束时显示高亮效果。默认：true
● setHighlightIndicatorEnabled(enabled: boolean): 如果设置为true， 选中数据时，将展示指标线。
● 此方法为dataset设置：setVisibleXRangeMaximum(maxXRange： number):设置x轴最多显示数据条数，（要在设置数据源后调用，否则是无效的）

**9.x轴和y轴的个性化样式是怎么设置？**

1）通过如下代码获取到 x 轴/y 轴对象。

```
//获取x轴
let xAxis = model.getXAxis();
//获取左y轴
let leftAxis = model.getAxisLeft();
//获取右y轴
let rightAxis = model.getAxisRight();
```

2）获取 x 轴和左右 y 轴对象之后，可以调用以下方法设置它们的属性

 setEnabled(enabled: boolean):设置轴是否被绘制。默认绘制，设置为false则不会被绘制。
● setDrawLabels(enabled: boolean):设置为true则绘制轴的标签。
● setDrawAxisLine(enabled: boolean): 设置为true则绘制轴线。
● setDrawGridLines(enabled: boolean): 设置为true则绘制网格线。
● setTextColor(color: string | number | CanvasGradient | CanvasPattern): 设置轴标签文本颜色。
● setTextSize(size: number):设置轴标签的字体大小。
● setTypeface(tf: FontFamily):设置轴标签的FontFamily，指定字体系列，支持如下几种类型：'sans-serif', 'serif', 'monospace'。
● setGridColor(color: number): 设置网格线颜色。
● setGridLineWidth(width: number):设置网格线宽度。
● setAxisLineColor(color: number):设置坐标轴的颜色。
● setAxisLineWidth(width: number): 设置坐标轴的宽度。
● enableGridDashedLine(lineLength: number, spaceLength: number, phase: number): 设置网格线虚线样式，"lineLength"控制短线条的长度，"spaceLength"控制两段线之间的间隔长度，"phase"控制开始的点。
● setAxisMaxValue(max: number):设置一个自定义的最大值，如果设置了数值，这个值将不会依赖于提供的数据自动计算。
● setAxisMinValue(min: number): 设置一个自定义的最小值。如果设置了数值，这个值将不会依赖于提供的数据进行自动计算。

3）x 轴专属设置：

● setAvoidFirstLastClipping(enabled: boolean):如果设置为true，图表将避免在图表或屏幕的边缘的标签条目被裁剪掉。
● setPosition(pos: XAxisPosition):设置XAxis应该出现的位置。可以选择TOP，BOTTOM，BOTH\_SIDED，TOP\_INSIDE或者BOTTOM\_INSIDE。

4）y轴专属设置：

● setInverted(enabled: boolean): 如果设置为true，这个轴将被反向，那意味着最大值将被放到底部，最小值将被放到顶部。
● setSpaceTop(percent: number):设置在图表上最高处的值相比轴上最高值的顶端空间（占总轴范围的百分比）。
● setSpaceBottom(percent: number): 设置在图表上最低处的值相比轴上最低处值的底部空间（总轴范围的百分比）。
● setPosition(pos: YAxisLabelPosition):设置轴标签应该被绘制的位置。INSIDE\_CHART或者OUTSIDE\_CHART中的一个。

**9.如何设置图表不抗锯齿？**

图表默认设置是抗锯齿的，把antiAliasing参数设置为false即可不抗锯齿：
LineChart({ model: this.model, antiAliasing: false })

## 约束与限制

在下述版本验证通过：
- DevEco Studio: 4.1 (4.1.3.521), SDK: API11 (4.1.0.65)
- DevEco Studio: NEXT Beta1-5.0.3.806, SDK: API12 Release (5.0.0.66) 

## 目录结构

````
|---- ohos-MPChart
|     |---- entry  # 示例代码文件夹
|     |---- library  # mpchart库文件夹
|           |---- index.ets  # 对外接口
│           ├----components # 框架代码目录
│                 ├----animation # 动画目录
│                 │      
│                 ├----buffer # 缓存相关目录
│                 │      
│                 ├----chartcomponents # 各类型图表目录
│                 │      
│                 ├----charts # 各类型图表Model类目录
│                 │      
│                 ├----components   # 自定义组件目录
│                 │          
│                 ├----data   # 数据实体目录
│                 │      
│                 ├----formatter # 各种数据格式化目录
│                 │      
│                 ├----highlight # 各种图表中高亮显示操作目录
│                 │      
│                 ├----interfaces   # 对外接口目录
│                 │          
│                 ├----jobs   # 动画工作线程目录
│                 │      
│                 ├----listener  # 手势监听目录
│                 │      
│                 ├----renderer  # 各种图表绘制属性设置目录
│                 │          
│                 └----utils  # 工具类目录
│                  
└─resources # 资源文件
|     |---- README.md  # 安装使用方法  

````

## 贡献代码
使用过程中发现任何问题都可以提 [Issue](https://gitee.com/openharmony-sig/ohos-MPChart/issues) 给我们，当然，我们也非常欢迎你给我们发 [PR](https://gitee.com/openharmony-sig/ohos-MPChart/pulls) 。

## 开源协议
本项目基于 [Apache License 2.0](https://gitee.com/openharmony-sig/ohos-MPChart/blob/master/LICENSE) ，请自由地享受和参与开源。
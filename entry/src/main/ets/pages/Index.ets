import CommonConstants from '../common/constants/CommonConstants';
import BillItemTable from '../common/database/tables/BillItemTable';
import Logger from '../common/utils/Logger';
import { TimeUtil } from '../common/utils/TimeUtil';
import { BillsListComponent } from '../view/BillsListComponent'
import { EditComponent } from '../view/EditComponent';

import { BillItem } from '../viewmodel/BillItem';

import {
  ChartGesture,
  ChartPixelMap, // 图表手势
  ColorTemplate,        // 颜色模板
  EntryOhos,            // 图表数据结构基础类
  Highlight,            // 高亮
  IPieDataSet,          // 饼状图数据集接口
  JArrayList,           // 工具类：数据集合
  Legend,               // 图表Legend(图例)部件
  MPPointF,
  OnChartGestureListener,   // 图表手势监听器接口
  OnChartValueSelectedListener,  // 图表数值选择监听器接口
  PieChart,             // 饼状图组件
  PieChartModel,        // 饼状图配置构建类
  PieData,              // 饼状图数据包
  PieDataSet,           // 饼状图数据集合
  PieEntry,             // 饼状图数据结构
} from '@ohos/mpchart';
import { ImageList, SearchList, TextList, TextList2 } from '../viewmodel/AccountList';
import MethodItem from '../viewmodel/MethodItem';
import { DividerTmp } from '../viewmodel/DividerTmp';
import { it } from '@ohos/hypium';
import App from '@system.app';

@Entry
@Component
struct Index {
  // @State chartGestureListener: OnChartGestureListener =undefined;

  @State currentIndex: number = 0;

  @State isEdit: boolean = false;
  @State isInsert: boolean = false;
  @State selectedDate:Date =new Date();

  @State deleteList: Array<BillItem> = [];

  @State  uniqueTimes: Array<string> = [];

  @State  listData: Array<BillItem> = [];

  @State searchList: Array<MethodItem> = SearchList;
  @State egDivider: DividerTmp = new DividerTmp(1, 60, 10, '#ffe9f0f0')

  @State totalIncomes:number =0;
  @State totalExpenses:number =0;
  @State searchMethod:string ='';
  @State searchType:number =0;


  @State   cash: number = 0;
  @State   wechatPayBalance: number = 0;
  @State   alipayBalance: number = 0;
  @State   applePayBalance: number = 0;
  @State   googlePayBalance: number = 0;
  @State   cardBalance: number = 0;
  @State   totalBalance: number =0;

  @State newBill: BillItem = {
    id:-1,
    remark:'',
    title:'',
    time:'',
    amount:0,
    method:'',
    accountType: 0
  };

  private timeUtil:TimeUtil =new TimeUtil();
  private BillItemTable = new BillItemTable(() => {});


  //tab_1
  private model: PieChartModel = new PieChartModel();



  // 第一步，创建TransitionEffect
  private  transitionTime: TransitionEffect = (TransitionEffect.IDENTITY)


  setDeleteAnimation() {
    this.transitionTime = (TransitionEffect.opacity(0)
      .animation({
        duration: 300,
      })).combine(TransitionEffect.asymmetric(TransitionEffect.move(TransitionEdge.END),
      TransitionEffect.move(TransitionEdge.START)))
  }

  setAddAnimation() {
    this.transitionTime = (TransitionEffect.opacity(0)
      .animation({
        duration: 300,
        delay: 100
      })).combine(TransitionEffect.asymmetric(TransitionEffect.move(TransitionEdge.END),
      TransitionEffect.move(TransitionEdge.START)))
  }



  dialogController: CustomDialogController = new CustomDialogController({
    builder: EditComponent({
      isInsert: $isInsert,
      newBill: $newBill,
      confirm: (isInsert: boolean, newAccount: BillItem) => this.accept(isInsert, newAccount)
    }),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  });
  
  
  onBalanceChange(){
    this.wechatPayBalance=0;
    this.alipayBalance=0;
    this.applePayBalance=0;
    this.googlePayBalance=0;
    this.cardBalance=0
    this.cash=0;
    let list =this.listData;

    list.forEach((item)=>{
      switch (item.method) {
        case 'wechatPay':
          item.accountType === 0 ? this.wechatPayBalance -= item.amount : this.wechatPayBalance += item.amount;
          break;
        case 'Alipay':
          item.accountType === 0 ? this.alipayBalance -= item.amount : this.alipayBalance += item.amount;
          break;
        case 'applePay':
          item.accountType === 0 ? this.applePayBalance -= item.amount : this.applePayBalance += item.amount;
          break;
        case 'googlePay':
          item.accountType === 0 ? this.googlePayBalance -= item.amount : this.googlePayBalance += item.amount;
          break;
        case 'card':
          item.accountType === 0 ? this.cardBalance -= item.amount : this.cardBalance += item.amount;
          break;
        default:
          console.error('Unknown payment method:', item.method);
      }

    })
    this.totalBalance=this.wechatPayBalance+this.alipayBalance+this.applePayBalance+this.googlePayBalance+this.cash+this.cardBalance;
  }

  accept(isInsert: boolean, newBill: BillItem): void {
    if (isInsert) {
      Logger.info(`${CommonConstants.INDEX_TAG}`, `The account inserted is:  ${JSON.stringify(newBill)}`);
      this.BillItemTable.insertData(newBill, (id: number) => {
        newBill.id = id;
        this.BillItemTable.getRdbStore(() => {
          this.BillItemTable.query(0, (result: BillItem[]) => {
            this.listData = result;
          }, true);
        });
      });
    }
    // else {
    //   this.BillItemTable.updateData(newBill, () => {
    //   });
    //   let list = this.listData;
    //   this.listData = [];
    //   list[this.index] = newBill;
    //   this.listData = list;
    //   this.index = -1;
    // }
  }

  onDataChange() {
    let list =this.listData;
    list.sort((a, b) => new Date(a.time).getTime()-new Date(b.time).getTime());
    const  unique: Set<string> = new Set();
    this.totalIncomes=0;
    this.totalExpenses=0;
    for (const item of list) {
      if (this.timeUtil.formatYearMonth(item.time)===this.timeUtil.formatYearMonth(this.selectedDate.toString())){
        if (item.accountType) {
          this.totalIncomes+=item.amount;
        }else {
          this.totalExpenses+=item.amount;
        }
        unique.add(this.timeUtil.formatMonthDay(item.time)+' '+this.timeUtil.getWeekday(item.time));  // 将 time 添加到 Set 中，自动去重
      }

    }
    if (this.uniqueTimes.length>0){
      this.uniqueTimes=[];
    }
    unique.forEach(item => {
      this.uniqueTimes.push(item);
    })
  }




  deleteListItem() {
    for (let i = 0; i < this.deleteList.length; i++) {
      let index = this.listData.indexOf(this.deleteList[i]);
      this.listData.splice(index, 1);
      this.BillItemTable.deleteData(this.deleteList[i], () => {
      });
    }
    this.deleteList = [];
    this.isEdit = false;
  }


  tab_0_aboutToAppear(){
    this.BillItemTable.getRdbStore(() => {
      this.BillItemTable.query(0, (result: BillItem[]) => {
        this.listData = result;

        let list =this.listData;
        list.sort((a, b) => new Date(a.time).getTime()-new Date(b.time).getTime());
        const  unique: Set<string> = new Set();
        this.totalIncomes=0;
        this.totalExpenses=0;
        for (const item of list) {
          if (item.accountType) {
            this.totalIncomes+=item.amount;
          }else {
            this.totalExpenses+=item.amount;
          }
          if (this.timeUtil.formatYearMonth(item.time)===this.timeUtil.formatYearMonth(this.selectedDate.toString())){
            unique.add(this.timeUtil.formatMonthDay(item.time)+' '+this.timeUtil.getWeekday(item.time));  // 将 time 添加到 Set 中，自动去重
          }
        }

        if (this.uniqueTimes.length>0){
          this.uniqueTimes=[];
        }
        unique.forEach(item => {
          this.uniqueTimes.push(item);
        })

        this.setData(4, 10);  // 设置图表数据
        this.onBalanceChange();
      }, true);

    });
  }

  tab_1_aboutToAppear(){
    // Step2：配置图表的特定样式，各部件间没有先后之分

    let l: Legend | null = this.model.getLegend();
    if (l) {
      l.setEnabled(true);
    }

    // this.model.animateXY(1000,1000);
    this.model.setNoDataText('未查询到数据')
    // this.model.setUsePercentValues(true);  // 使用百分比值
    this.model.getDescription()?.setEnabled(false);  // 禁用描述信息
    this.model.setExtraOffsets(5, 10, 5, 5);  // 设置额外偏移量

    // this.model.setOnChartGestureListener(this.chartGestureListener);  // 设置图表手势监听器

    this.model.setDragDecelerationFrictionCoef(0.95);  // 设置拖动减速摩擦系数

    this.model.setCenterText(this.searchType===0?'总支出':'总收入');  // 设置中心文本
    this.model.setCenterTextSize(22);  // 设置中心文本大小

    this.model.setDrawHoleEnabled(true);  // 启用绘制中心孔
    this.model.setHoleColor(Color.White);  // 设置中心孔颜色

    this.model.setTransparentCircleColor(Color.Red);  // 设置透明圆环颜色
    this.model.setTransparentCircleAlpha(110);  // 设置透明圆环透明度

    this.model.setHoleRadius(25);  // 设置中心孔半径
    this.model.setTransparentCircleRadius(28);  // 设置透明圆环半径

    this.model.setDrawCenterText(true);  // 绘制中心文本

    this.model.setRotationAngle(0);  // 设置旋转角度
    // 通过触摸启用图表的旋转
    this.model.setRotationEnabled(true);
    this.model.setHighlightPerTapEnabled(true);  // 启用点击高亮效果

    // this.setData(4, 10);  // 设置图表数据
  }
  // 根据 title 累加 amount
  accumulateByTitle(billItems: BillItem[],selectedDate:Date): Map<string, number> {

    const result: Map<string, number> = new Map();

    billItems.forEach(item => {
      if (item.accountType===this.searchType&&this.timeUtil.formatYearMonth(selectedDate.toString())===this.timeUtil.formatYearMonth(item.time)) {
        if (this.searchMethod==='') {
          const currentAmount = result.get(item.title) || 0;  // 如果没有这个 title，默认为 0
          result.set(item.title, currentAmount + item.amount);  // 累加金额
        }
        else if(this.searchMethod===item.method){
          const currentAmount = result.get(item.title) || 0;  // 如果没有这个 title，默认为 0
          result.set(item.title, currentAmount + item.amount);  // 累加金额
        }
      }
    });

    return result;
  }

  // 初始化饼状图数据
  private async setData(count: number, range: number): Promise<void> {
    let entries: JArrayList<PieEntry> = new JArrayList<PieEntry>();

    // NOTE: The order of the entries when being added to the entries array determines their position around the center of
    // the chart.

    const list =this.listData;


    let ret=this.accumulateByTitle(list,this.selectedDate);

    ret.forEach((value,key)=>{
      entries.add(new PieEntry(value,TextList2[key]))
    })

    // 创建饼状图数据集对象，设置数据项和数据集名称
    let dataSet: PieDataSet = new PieDataSet(entries, "by 不秋");
    // 设置是否绘制数据项图标
    dataSet.setDrawIcons(false);
    // 设置数据项之间的间隙
    dataSet.setSliceSpace(1);
    // 设置数据项图标的偏移量
    dataSet.setIconsOffset(new MPPointF(0, 40));
    // 设置选中时数据项的偏移距离
    dataSet.setSelectionShift(10);
    // 设置数据项文本颜色
    dataSet.setValueTextColor(Color.Black);

    dataSet.setValueTextSize(20)
    dataSet.setFormSize(30)


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



  aboutToAppear() {
    this.tab_0_aboutToAppear();
    this.tab_1_aboutToAppear();
  }



  scroller: Scroller = new Scroller()

  @Builder tabBuilder(title: string, targetIndex: number, selectedImg: Resource, normalImg: Resource) {
    Column() {
      Image(this.currentIndex === targetIndex ? selectedImg : normalImg)
        .size({ width: 30, height: 30 })
        .offset({ y: 3 })
      Text(title)
        .fontColor(this.currentIndex === targetIndex ? '#2D914D' : '#bfbfbf')
        .offset({ y: 3 })
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
  }


  build() {
    Tabs({ barPosition: BarPosition.End }) {

      TabContent() {
        Column(){

          //标题和批量删除模块
          Row() {
            Text('账单')
              .height($r('app.float.component_size_SP'))
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .margin({ left: $r('app.float.font_size_L') })

            Button(){
              Image($rawfile('ic_public_edit.svg'))
                .width($r('app.float.component_size_S'))
                .margin(10)
                // .backgroundColor(Color.White)
                // .aspectRatio(CommonConstants.FULL_SIZE)
                // .margin({ right: $r('app.float.font_size_L') })
            }.onClick(() => {
              this.isEdit = !this.isEdit;
            })
            .borderRadius(25)
            .margin({ right: $r('app.float.font_size_L') })
            .backgroundColor(Color.White)

          }
          .width(CommonConstants.FULL_WIDTH)
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ top: $r('app.float.edge_size_M'), bottom: $r('app.float.edge_size_MM') })

          //时间切换模块
          Row(){
            //左箭头，减少月份
            Button(){
              Image($r('app.media.chevron_left'))
                .width(12)
                .height(12)
                .margin(6)
            }
            .onClick(()=>{
              this.setAddAnimation()
              animateTo({
                duration: 500, curve: Curve.Smooth, onFinish: () => {
                  this.transitionTime = (TransitionEffect.IDENTITY)
                }
              }, () => {
                this.selectedDate.setMonth(this.selectedDate.getMonth()-1);
                this.onDataChange();
              })


            })
            .borderRadius(6)
            .backgroundColor(Color.White)


            //显示月份，点击后可以弹窗选择月份
            Text(this.timeUtil.formatYearMonth(this.selectedDate.toString()))
              .fontWeight(FontWeight.Bold)
              .onClick(()=>{
                DatePickerDialog.show({ // 建议使用 this.getUIContext().showDatePickerDialog()接口
                  start: new Date("2000-1-1"),
                  end: new Date("2100-12-31"),
                  selected: this.selectedDate,
                  showTime:false,
                  useMilitaryTime:false,
                  disappearTextStyle: {color: Color.Black, font: {size: '14fp', weight: FontWeight.Regular}},
                  textStyle: {color: Color.Black, font: {size: '18fp', weight: FontWeight.Normal}},
                  selectedTextStyle: {color: Color.Black, font: {size: '22fp', weight: FontWeight.Bold}},
                  onDateAccept: (value: Date) => {
                    // 通过Date的setFullYear方法设置按下确定按钮时的日期，这样当弹窗再次弹出时显示选中的是上一次确定的日期
                    this.selectedDate = value
                    // const daysOfWeek = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
                    // const dayIndex = this.selectedDate.getDay();
                    // const weekday=daysOfWeek[dayIndex];
                    // this.newBill.time = this.selectedDate.toString();
                    console.info("DatePickerDialog:onDateAccept()" + value.toString())
                  },
                  onCancel: () => {
                    console.info("DatePickerDialog:onCancel()")
                  },
                  onDateChange: (value: Date) => {
                    console.info("DatePickerDialog:onDateChange()" + value.toString())
                  },
                  onDidAppear: () => {
                    console.info("DatePickerDialog:onDidAppear()")
                  },
                  onDidDisappear: () => {
                    this.onDataChange();
                    console.info("DatePickerDialog:onDidDisappear()")
                  },
                  onWillAppear: () => {
                    console.info("DatePickerDialog:onWillAppear()")
                  },
                  onWillDisappear: () => {
                    console.info("DatePickerDialog:onWillDisappear()")
                  }
                })
              })
              .margin({left:10,right:10})


            //右箭头，增加月份
            Button(){
              Image($r('app.media.chevron_right'))
                .width(12)
                .height(12)
                .margin(6)
            }
            .onClick(()=>{
              this.setAddAnimation()
              animateTo({
                duration: 500, curve: Curve.Smooth, onFinish: () => {
                  this.transitionTime = (TransitionEffect.IDENTITY)
                }
              }, () => {
                this.selectedDate.setMonth(this.selectedDate.getMonth()+1);
                this.onDataChange();
              })

            })
            .borderRadius(6)
            .backgroundColor(Color.White)
          }
          .width('90%')
          .margin({left:10,bottom:10})
          .justifyContent(FlexAlign.Start)

          Row(){
            //总收入模块
            Column(){
              Row(){
                Image($r('app.media.wallet'))
                  .backgroundColor('#E74C3C')
                  .width(25)
                  .padding(5)
                  .borderRadius(12.5)
                  .margin({right:5})
                Text('总支出')
                  .fontWeight(FontWeight.Bold)
                  .fontSize(16)
                  .fontColor('#E74C3C')
              }
              .margin({bottom:10})
              Text('￥'+this.totalExpenses.toString())
                .fontWeight(FontWeight.Bold)
                .fontSize(25)
            }
            .alignItems(HorizontalAlign.Start)
            .backgroundColor(Color.White)
            .borderRadius(18)
            .width('40%')
            .padding(15)
            //总支出模块
            Column(){
              Row(){
                Image($r('app.media.wallet'))
                  .width(25)
                  .borderRadius(12.5)
                  .padding(5)
                  .margin({right:5})
                  .backgroundColor('#27AE60')
                Text('总收入')
                  .fontWeight(FontWeight.Bold)
                  .fontSize(16)
                  .fontColor('#27AE60')
              }
              .margin({bottom:10})
              Text('￥'+this.totalIncomes.toString())
                .fontWeight(FontWeight.Bold)
                .fontSize(25)

            }
            .alignItems(HorizontalAlign.Start)
            .borderRadius(18)
            .backgroundColor(Color.White)
            .padding(15)
            .width('40%')

          }
          .width('90%')
          .margin({left:10,right:10,bottom:10})
          .justifyContent(FlexAlign.SpaceBetween)

          //账单模块
          Stack(){
            Scroll(this.scroller){
              Column(){
                ForEach(this.uniqueTimes, (item: string, index: number) => {
                  BillsListComponent({listData:this.listData,isEdit:this.isEdit,deleteList:this.deleteList,time:item,uniqueTimes:this.uniqueTimes,selectedDate:this.selectedDate,totalIncomes:this.totalIncomes,totalExpenses:this.totalExpenses})
                    .width('100%')
                    .transition(this.transitionTime)
                })
              }
              .width('100%')
            }
            .align(Alignment.Top)
            .height('68%')
            .width('100%')

            //添加账单模块
            if (!this.isEdit) {
              Button() {
                Image($rawfile('plus.svg'))
                  .borderRadius(24)
                  .padding(12)
                  .backgroundColor('#27AE60')
              }
              .width($r('app.float.component_size_MP'))
              .height($r('app.float.component_size_MP'))
              .position({ x: CommonConstants.EDIT_POSITION_X, y: CommonConstants.EDIT_POSITION_Y })
              .onClick(() => {
                this.isInsert = true;
                this.dialogController.open();
                // this.onDataChange();
              }).onDisAppear(()=>{
                this.onDataChange();
                this.onBalanceChange();
              })
            }
            //编辑账单模块
            if (this.isEdit) {
              Button() {
                Image($rawfile('delete.png'))
              }
              .width($r('app.float.component_size_MP'))
              .height($r('app.float.component_size_MP'))
              .backgroundColor($r('app.color.background_color'))
              .markAnchor({ x: $r('app.float.mark_anchor'), y: CommonConstants.MINIMUM_SIZE })
              .position({ x: CommonConstants.DELETE_POSITION_X, y: CommonConstants.DELETE_POSITION_Y })
              .onClick(() => {
                this.deleteListItem();
                // this.onDataChange()
              })
              .onDisAppear(()=>this.onDataChange())
            }
          }
        }


      }
      .tabBar(this.tabBuilder('账本', 0, $r('app.media.ledger_selected'), $r('app.media.ledger')))



      TabContent() {
        Column(){
          Row() {
            Text('统计')
              .height($r('app.float.component_size_SP'))
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .margin({ left: $r('app.float.font_size_L') })

          }
          .width(CommonConstants.FULL_WIDTH)
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ top: $r('app.float.edge_size_M'), bottom: $r('app.float.edge_size_MM') })
          Scroll(this.scroller) {
            Row() {
              ForEach(this.searchList, (item: MethodItem) => {
                Column() {
                  Image(item.icon)
                    // .fillColor(Color.White)
                    // .fillColor(this.searchMethod === item.typeText?Color.White:Color.Black)
                    .width($r('app.float.image_size'))
                  // .aspectRatio(CommonConstants.FULL_SIZE)

                  Text(item.typeText)
                    .fontSize($r('app.float.font_size_S'))
                    // .fontColor(this.searchMethod === item.typeText ? Color.White : $r('app.color.main_color'))
                    .margin({ top: $r('app.float.edge_size_S') })
                }
                .width($r('app.float.component_size_LP'))
                .aspectRatio(CommonConstants.FULL_SIZE)
                .padding({ top: $r('app.float.edge_size_M') })
                .margin({ top: $r('app.float.edge_size_MP'), left: $r('app.float.edge_size_M') })
                .align(Alignment.TopStart)
                // .backgroundColor(this.searchMethod === item.typeText ? Color.White : $r('app.color.main_color'))
                .backgroundColor(this.searchMethod === item.typeText ? ' #D3D3D3' : Color.White)
                .borderRadius($r('app.float.radius_size_S'))
                .onClick(() => {
                  if (this.searchMethod===item.typeText) {
                    this.searchMethod='';
                  }
                  else {
                    this.searchMethod=item.typeText;
                  }
                  this.setData(4, 10);  // 设置图表数据
                  this.model.invalidate();


                  // this.newBill.method = item.typeText;
                  // this.curMethod = item.typeText;
                })
              })
            }
          }
          .margin({top:10})
          .borderRadius(40)
          .backgroundColor(Color.White)
          .width('75%')
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)

          Row(){
            Row(){
              Button(){
                Image($r('app.media.chevron_left'))
                  .width(12)
                  .height(12)
                  .margin(6)
              }
              .onClick(()=>{
                this.selectedDate.setMonth(this.selectedDate.getMonth()-1);

                this.onDataChange();
                this.setData(4, 10);  // 设置图表数据
                this.model.invalidate();
              })
              // .onDisAppear(()=>{
              //   this.onDataChange()
              // })
              .borderRadius(6)
              .backgroundColor(Color.White)


              Text(this.timeUtil.formatYearMonth(this.selectedDate.toString()))
                .fontWeight(FontWeight.Bold)
                .onClick(()=>{
                  DatePickerDialog.show({ // 建议使用 this.getUIContext().showDatePickerDialog()接口
                    start: new Date("2000-1-1"),
                    end: new Date("2100-12-31"),
                    selected: this.selectedDate,
                    showTime:false,
                    useMilitaryTime:false,
                    disappearTextStyle: {color: Color.Black, font: {size: '14fp', weight: FontWeight.Regular}},
                    textStyle: {color: Color.Black, font: {size: '18fp', weight: FontWeight.Normal}},
                    selectedTextStyle: {color: Color.Black, font: {size: '22fp', weight: FontWeight.Bold}},
                    onDateAccept: (value: Date) => {
                      // 通过Date的setFullYear方法设置按下确定按钮时的日期，这样当弹窗再次弹出时显示选中的是上一次确定的日期
                      this.selectedDate = value
                      this.setData(4, 10);  // 设置图表数据
                      this.model.invalidate();
                      // const daysOfWeek = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
                      // const dayIndex = this.selectedDate.getDay();
                      // const weekday=daysOfWeek[dayIndex];
                      // this.newBill.time = this.selectedDate.toString();
                      console.info("DatePickerDialog:onDateAccept()" + value.toString())
                    },
                    onCancel: () => {
                      console.info("DatePickerDialog:onCancel()")
                    },
                    onDateChange: (value: Date) => {
                      console.info("DatePickerDialog:onDateChange()" + value.toString())
                    },
                    onDidAppear: () => {
                      console.info("DatePickerDialog:onDidAppear()")
                    },
                    onDidDisappear: () => {
                      this.onDataChange();
                      console.info("DatePickerDialog:onDidDisappear()")
                    },
                    onWillAppear: () => {
                      console.info("DatePickerDialog:onWillAppear()")
                    },
                    onWillDisappear: () => {
                      console.info("DatePickerDialog:onWillDisappear()")
                    }
                  })
                })
                .margin({left:10,right:10})


              Button(){
                Image($r('app.media.chevron_right'))
                  .width(12)
                  .height(12)
                  .margin(6)
              }
              .onClick(()=>{
                this.selectedDate.setMonth(this.selectedDate.getMonth()+1);
                this.onDataChange();
                this.setData(4, 10);  // 设置图表数据
                this.model.invalidate();
                // dataSet.notifyDataSetChanged();
              })
              .borderRadius(6)
              .backgroundColor(Color.White)
            }
            .width('70%')
            .margin({top:20,left:10,bottom:10})
            .justifyContent(FlexAlign.Start)

            Button(this.searchType===0?'支出':'收入', { type: ButtonType.Capsule, stateEffect: true })
              .backgroundColor(Color.White)
              .onClick(()=>{
                if (this.searchType===0) {
                  this.searchType=1;
                }
                else{
                  this.searchType=0;
                }
                this.setData(4, 10);  // 设置图表数据
                this.model.invalidate();
                this.model.setCenterText(this.searchType===0?'总支出':'总收入');  // 设置中心文本

              })
              .fontColor(Color.Black)
              .width(90)

          }
          .width('90%')


          PieChart({ model: this.model })
            .width('100%')
            .height('60%')
        }

        // MainPage()
      }
      .align(Alignment.Top)
      .height('100%')
      .width('100%')
      .tabBar(this.tabBuilder('统计', 1, $r('app.media.statistics_selected'), $r('app.media.statistics')))



      TabContent() {
        Column(){

          Row() {

            Row(){
              Text('我的资产')
                .height($r('app.float.component_size_SP'))
                .fontSize(30)
                .fontWeight(FontWeight.Bold)
                .margin({ left: $r('app.float.font_size_L') })

              Button(){
                Image($r('app.media.avatar'))
                  .width(33)
                  .margin(3)
                  .borderRadius(17)
                // .backgroundColor(Color.White)
                // .aspectRatio(CommonConstants.FULL_SIZE)
                // .margin({ right: $r('app.float.font_size_L') })
              }
              .borderRadius(25)
              .margin({ right: $r('app.float.font_size_L') })
              .backgroundColor(Color.White)
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%')


          }
          .width(CommonConstants.FULL_WIDTH)
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ top: $r('app.float.edge_size_M'), bottom: $r('app.float.edge_size_MM') })

          Row(){
            Column(){
              Text('净资产')
                .fontSize(14)
                .fontColor('#8F8F8F')
              Text('￥'+this.totalBalance)
                .margin({
                  top:10,
                  bottom:10
                })
                .fontWeight(FontWeight.Bold)
                .fontSize(30)
              Row(){
                Text('总资产 ￥'+ this.totalBalance)
                  .fontSize(14)
                  .fontColor('#8F8F8F')
                  .margin({right:20})
                Text('总负债 ￥0')
                  .fontSize(14)
                  .fontColor('#8F8F8F')
              }
            }
            .width('88%')
            .padding(20)
            .borderRadius(18)
            .backgroundColor(Color.White)
            .margin({left:24})
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')

          Row(){
            Text('现金')
              .fontSize(18)
              .margin({
                top:10,
                bottom:10
              })
              .fontColor('#8F8F8F')
          }
          .width('90%')

          Row() {
            Row(){
              // 图标
              Image($r('app.media.cash'))
                .width(40)
                  // .height(40)
                  // .borderRadius(20)
                  // .backgroundColor(item.accountType===0?Color.Red:Color.Green)
                  // .fillColor(Color.White)
                .padding(7)
                .margin({right:10 });

              // 文本内容
              Column() {
                Text('现金').fontSize(16).fontWeight('medium');
                // Text(this.timeUtil.formatTime(item.time)).fontSize(12).fontColor('#8F8F8F');
              }
              .alignItems(HorizontalAlign.Start)
              // .margin(10);
            }

            Row(){
              // 金额与支付方式
              Column() {
                Text('￥'+this.cash.toString())
                  .fontSize(16)
                  .fontWeight('medium');

              }
              .justifyContent(FlexAlign.SpaceBetween)

            }

          }
          .padding({ bottom: 10,left: 10,right: 10,top: 10})
          // .backgroundColor(Color.Red)
          .borderRadius(18)
          .backgroundColor('#FFFFFF')
          .justifyContent(FlexAlign.SpaceBetween)
          .width("90%")

          Row(){
            Text('网络支付')
              .margin({
                top:10,
                bottom:10
              })
              .fontSize(18)
              .fontColor('#8F8F8F')
          }
          .width('88%')


          List(){
            ForEach(this.searchList, (item: MethodItem, index: number) => {
              ListItem() {
                Row() {
                  Row() {
                    // 图标
                    Image(item.icon)
                      .width(40)
                      .borderRadius(20)// .backgroundColor(item.accountType===0?Color.Red:Color.Green)
                      .padding(7)
                      .margin({ right: 10 });

                    // 文本内容
                    Column() {
                      Text(TextList[item.typeText]).fontSize(16).fontWeight('medium');
                      // Text(this.timeUtil.formatTime(item.time)).fontSize(12).fontColor('#8F8F8F');
                    }
                    .alignItems(HorizontalAlign.Start)

                  }

                  Row() {
                    // 金额与支付方式
                    Column() {

                      Text(item.typeText==='wechatPay'?'￥'+this.wechatPayBalance.toString():
                          item.typeText==='Alipay'?'￥'+this.alipayBalance.toString():
                          item.typeText==='applePay'?'￥'+this.applePayBalance.toString():
                          item.typeText==='googlePay'?'￥'+this.googlePayBalance.toString():
                          item.typeText==='card'?'￥'+this.cardBalance.toString(): '￥'+this.wechatPayBalance.toString())
                        .fontSize(16)
                        .fontWeight('medium');

                    }

                  }
                  .justifyContent(FlexAlign.SpaceBetween)

                }
                .padding({
                  bottom: 10,
                  left: 10,
                  right: 10,
                  top: 10
                })
                // .backgroundColor(Color.Red)
                .backgroundColor('#FFFFFF')
                .justifyContent(FlexAlign.SpaceBetween)
                .width("100%")

                // .alignItems(VerticalAlign.Center)
              }
            })
          }
          .backgroundColor('#F1F3F5')
          .divider(this.egDivider)
          .width("90%")
          .borderRadius(15)


        }
        .height('95%')

      }
      .tabBar(this.tabBuilder('资产', 2, $r('app.media.assets_selected'), $r('app.media.assets')))

    }
    .animationDuration(400)
    // .backgroundColor('#F1F3F5')
    .onChange((index: number) => {
      this.currentIndex = index;
      this.onBalanceChange();
    })
    .height('100%')
    .width('100%')
    .backgroundColor('#F1F3F5')
  }
}

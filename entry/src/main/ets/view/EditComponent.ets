import CommonConstants from "../common/constants/CommonConstants";
import AccountItem from "../viewmodel/AccountItem";
import { EarnList, MethodList, PayList, TextList } from "../viewmodel/AccountList";
import { BillItem } from "../viewmodel/BillItem";
import { promptAction } from "@kit.ArkUI";
import { TimeUtil } from "../common/utils/TimeUtil";
import MethodItem from "../viewmodel/MethodItem";


@CustomDialog
export struct EditComponent {

  controller?: CustomDialogController;
  @Link newBill: BillItem;
  @Link isInsert: boolean;
  @State curIndex: number = 0;  //收入支出
  private scroller: Scroller = new Scroller();
  private timeUtil: TimeUtil =new TimeUtil();
  @State payList: Array<AccountItem> = PayList;
  @State earnList: Array<AccountItem> = EarnList;
  @State methodList:Array<MethodItem> = MethodList;

  confirm?: (isInsert: boolean, newBill: BillItem) => void;

  @State selectedDate: Date = new Date();
  @State weekday:string ='';
  private inputAmount = '';
  private inputRemark ='';
  @State curType: string = '';   //账单类型
  @State curMethod: string ='';
  @State time:string ='';
  @State timeText:string = '';

  @Builder
  TabBuilder(index: number) {
    Column() {
      Text(index === 0 ? $r('app.string.pay_text') : $r('app.string.income_text'))
        .fontSize($r('app.float.font_size_M'))
        .fontColor(this.curIndex === index ? $r('app.color.main_color') : Color.Gray)
    }
    .width($r('app.float.component_size_LM'))
    .padding({ top: $r('app.float.edge_size_LM'), bottom: $r('app.float.edge_size_S') })
    .margin({ bottom: $r('app.float.edge_size_S') })
    .border({
      width: { bottom: this.curIndex === index ? $r('app.float.border_size_M') : '' },
      color: this.curIndex === index ? $r('app.color.main_color') : Color.White
    })
  }

  @Builder
  timeBuilder(){
    Row(){
        Image($r('app.media.chevron_down'))
          .margin(20)
          .width(20)
          .onClick(() => {
            DatePickerDialog.show({ // 建议使用 this.getUIContext().showDatePickerDialog()接口
              start: new Date("2000-1-1"),
              end: new Date("2100-12-31"),
              selected: this.selectedDate===new Date()?this.selectedDate:new Date(this.time),
              showTime:true,
              useMilitaryTime:false,
              disappearTextStyle: {color: Color.Black, font: {size: '14fp', weight: FontWeight.Regular}},
              textStyle: {color: Color.Black, font: {size: '18fp', weight: FontWeight.Normal}},
              selectedTextStyle: {color: Color.Black, font: {size: '22fp', weight: FontWeight.Bold}},
              onDateAccept: (value: Date) => {
                // 通过Date的setFullYear方法设置按下确定按钮时的日期，这样当弹窗再次弹出时显示选中的是上一次确定的日期
                this.selectedDate = value
                this.timeText=this.timeUtil.formatYearMonthDay(value.toString());
                // const daysOfWeek = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
                // const dayIndex = this.selectedDate.getDay();
                // const weekday=daysOfWeek[dayIndex];
                this.newBill.time = this.selectedDate.toString();
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


    }

  }


  aboutToAppear() {
    this.inputAmount = this.newBill.amount.toString();
    this.inputRemark = this.newBill.remark.toString();
    this.curIndex = this.newBill.accountType;
    this.curMethod= this.newBill.method;
    this.curType = this.newBill.title;
    this.time = this.newBill.time;
    this.timeText=this.time===''?'选择时间':this.timeUtil.formatYearMonthDay(this.time);
    //添加其他信息
  }

  selectAccount(item: AccountItem) {
    this.newBill.accountType = item.accountType;
    this.newBill.title = item.typeText;
    this.curType = item.typeText;
  }


  build() {

    Column() {
      Image($rawfile('half.png'))
        .width($r('app.float.component_size_L'))
        .height($r('app.float.component_size_S'))
        .onClick(() => {
          this.controller?.close();
        })

      Tabs({ barPosition: BarPosition.Start, index: this.curIndex }) {
        TabContent() {
          Scroll(this.scroller) {
            Row() {
              ForEach(this.payList, (item: AccountItem) => {
                Column() {
                  Image(item.icon)
                    // .fillColor(Color.White)
                    .fillColor(this.curType === item.typeText?Color.White:Color.Black)
                    // .backgroundColor(item.accountType===0?Color.Red:Color.Green)
                    .width($r('app.float.image_size'))
                    .aspectRatio(CommonConstants.FULL_SIZE)

                  Text(TextList[item.typeText])
                    .fontSize($r('app.float.font_size_S'))
                    .fontColor(this.curType === item.typeText ? Color.White : $r('app.color.main_color'))
                    .margin({ top: $r('app.float.edge_size_S') })
                }
                .width($r('app.float.component_size_LP'))
                .aspectRatio(CommonConstants.FULL_SIZE)
                .padding({ top: $r('app.float.edge_size_M') })
                .margin({ top: $r('app.float.edge_size_MP'), left: $r('app.float.edge_size_M') })
                .align(Alignment.TopStart)
                .backgroundColor(this.curType === item.typeText ? $r('app.color.main_color') : $r('app.color.background_color'))
                .borderRadius($r('app.float.radius_size_S'))
                .onClick(() => {
                  this.selectAccount(item);
                })
              })
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
        }
        .tabBar(this.TabBuilder(0))
        // .margin({ bottom: $r('app.float.edge_size_LP') })

        TabContent() {
          Scroll(this.scroller) {
            Row() {
              ForEach(this.earnList, (item: AccountItem) => {
                Column() {
                  Image(item.icon)
                    // .fillColor(Color.White)
                    .fillColor(this.curType === item.typeText?Color.White:Color.Black)
                    .width($r('app.float.image_size'))
                    .aspectRatio(CommonConstants.FULL_SIZE)

                  Text(TextList[item.typeText])
                    .fontSize($r('app.float.font_size_S'))
                    .fontColor(this.curType === item.typeText ? Color.White : $r('app.color.main_color'))
                    .margin({ top: $r('app.float.edge_size_S') })
                }
                .width($r('app.float.component_size_LP'))
                .aspectRatio(CommonConstants.FULL_SIZE)
                .padding({ top: $r('app.float.edge_size_M') })
                .margin({ top: $r('app.float.edge_size_MP'), left: $r('app.float.edge_size_M') })
                .align(Alignment.TopStart)
                .backgroundColor(this.curType === item.typeText ? $r('app.color.main_color') : $r('app.color.background_color'))
                .borderRadius($r('app.float.radius_size_S'))
                .onClick(() => {
                  this.selectAccount(item);
                })
              })
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
        }
        .tabBar(this.TabBuilder(1))
        // .margin({ bottom: $r('app.float.edge_size_LP') })
      }
      .width(CommonConstants.FULL_WIDTH)
      .height(CommonConstants.TABS_HEIGHT)
      .vertical(false)
      .barMode(BarMode.Fixed)
      .onChange((index) => {
        this.curIndex = index;
      })

      Row(){
        Text('支付方式')
          .width('20%')
          .margin({left:12})
        Scroll(this.scroller) {
          Row() {
            ForEach(this.methodList, (item: MethodItem) => {
              Column() {
                Image(item.icon)
                  // .fillColor(Color.White)
                  // .fillColor(this.curMethod === item.typeText?Color.White:Color.Black)
                  .width($r('app.float.image_size'))
                  // .aspectRatio(CommonConstants.FULL_SIZE)

                Text(TextList[item.typeText])
                  .fontSize($r('app.float.font_size_S'))
                  .fontColor(this.curMethod === item.typeText ? Color.White : $r('app.color.main_color'))
                  .margin({ top: $r('app.float.edge_size_S') })
              }
              .width($r('app.float.component_size_LP'))
              .aspectRatio(CommonConstants.FULL_SIZE)
              .padding({ top: $r('app.float.edge_size_M') })
              .margin({ top: $r('app.float.edge_size_MP'), left: $r('app.float.edge_size_M') })
              .align(Alignment.TopStart)
              .backgroundColor(this.curMethod === item.typeText ?  '#D3D3D3' : $r('app.color.background_color'))
              .borderRadius($r('app.float.radius_size_S'))
              .onClick(() => {
                this.newBill.method = item.typeText;
                this.curMethod = item.typeText;
              })
            })
          }
        }
        .width('75%')
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
      }
      .width('100%')



      // Column() {
      //   Row(){
      //     Text($r('app.string.count_text'))
      //       .margin({right:12})
      //       // .width(CommonConstants.FULL_WIDTH)
      //       // .fontSize($r('app.float.font_size_MP'))
      //       // .fontColor(Color.Black)
      //
      //     Column() {
      //       TextInput({
      //         placeholder: $r('app.string.input_text'),
      //         text: this.newBill.amount === 0 ? this.inputAmount : this.newBill.amount.toString()
      //       })
      //         // .focusable(false)
      //         .padding({
      //           left: CommonConstants.MINIMUM_SIZE,
      //           top: CommonConstants.MINIMUM_SIZE,
      //           bottom: CommonConstants.MINIMUM_SIZE
      //         })
      //         .borderRadius(CommonConstants.MINIMUM_SIZE)
      //         .backgroundColor(Color.White)
      //         .type(InputType.Number)
      //         .onChange((value: string) => {
      //           this.inputAmount = value;
      //         })
      //     }
      //     .height($r('app.float.component_size_MP'))
      //     .padding({ top: $r('app.float.edge_size_MPM'), bottom: $r('app.float.edge_size_MM') })
      //     .borderWidth({ bottom: CommonConstants.FULL_SIZE })
      //     .borderColor($r('app.color.border_color'))
      //   }
      // }
      // .width(CommonConstants.FULL_WIDTH)
      // .padding({ left: $r('app.float.edge_size_M'), right: $r('app.float.edge_size_M') })


      Row(){
        Row(){
          Text('金额：')
            .margin({left:12})
          // .width(CommonConstants.FULL_WIDTH)
          // .fontSize($r('app.float.font_size_MP'))
          // .fontColor(Color.Black)

          Column() {
            TextInput({
              placeholder: $r('app.string.input_text'),
              text: this.newBill.amount === 0 ? this.inputAmount : this.newBill.amount.toString()
            })
              .padding({
                left: CommonConstants.MINIMUM_SIZE,
                top: CommonConstants.MINIMUM_SIZE,
                bottom: CommonConstants.MINIMUM_SIZE
              })
              .borderRadius(CommonConstants.MINIMUM_SIZE)
              .backgroundColor(Color.White)
              .type(InputType.Number)
              .onChange((value: string) => {
                this.inputAmount = value;
              })
          }
          .height($r('app.float.component_size_MP'))
          .padding({ top: $r('app.float.edge_size_MPM'), bottom: $r('app.float.edge_size_MM') })
          // .borderWidth({ bottom: CommonConstants.FULL_SIZE })
          .borderColor($r('app.color.border_color'))
        }
        .width('40%')


        Row(){
          Text(this.timeText);
          this.timeBuilder();
        }

      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Row(){
        Text('备注：')
          .margin({left:12})
        TextInput({placeholder: '请输入备注',
        text: this.newBill.remark === '' ? this.inputRemark : this.newBill.remark.toString()})
          .onChange((value: string) => {
            this.inputRemark = value;
          })
          .type(InputType.Normal)
          .backgroundColor(Color.White)
      }


      Column() {
        Button() {
          Text($r('app.string.confirm_text'))
            .fontSize($r('app.float.font_size_M'))
            .fontColor(Color.White)
        }
        .width(CommonConstants.FULL_WIDTH)
        .height($r('app.float.component_size_M'))
        .onClick(() => {
          if (this.newBill.title === '' || this.curIndex !== this.newBill.accountType) {
            promptAction.showToast({ message: CommonConstants.TOAST_TEXT_1, bottom: CommonConstants.PROMPT_BOTTOM });
          } else {
            let regex: RegExp = new RegExp('[1-9][0-9]*');
            let matchValue: Array<string> | null = this.inputAmount.match(regex);
            if (matchValue !== null && matchValue[0] === this.inputAmount) {
              this.newBill.amount = Number(this.inputAmount);
              this.newBill.remark =this.inputRemark;
              this.confirm && this.confirm(this.isInsert, this.newBill);
              this.controller?.close();
            } else {
              promptAction.showToast({ message: CommonConstants.TOAST_TEXT_2, bottom: CommonConstants.PROMPT_BOTTOM });
            }
          }
        })
      }
      .layoutWeight(CommonConstants.FULL_SIZE)
      .padding({
        bottom: $r('app.float.font_size_L'),
        left: $r('app.float.font_size_L'),
        right: $r('app.float.font_size_L')
      })
      .justifyContent(FlexAlign.End)
    }
    .width(CommonConstants.FULL_WIDTH)
    .height(CommonConstants.DIALOG_HEIGHT)
    .borderRadius({ topLeft: $r('app.float.font_size_L'), topRight: $r('app.float.font_size_L') })
    .backgroundColor(Color.White)
    .align(Alignment.BottomEnd)

  }
}
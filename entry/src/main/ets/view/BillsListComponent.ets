
import BillItemTable from '../common/database/tables/BillItemTable';
import { TimeUtil } from '../common/utils/TimeUtil';
import { ImageList, TextList } from '../viewmodel/AccountList';
import { BillItem } from '../viewmodel/BillItem';
import { DividerTmp } from '../viewmodel/DividerTmp';
import { EditComponent } from './EditComponent';
import { curves } from '@kit.ArkUI';


// 主页面组件
@Component
export struct BillsListComponent {
  @Link listData: Array<BillItem> ;

  private time:string ='';
  private timeUtil:TimeUtil =new TimeUtil();

  @State isInsert: boolean = false;
  @Link isEdit: boolean ;
  @State index: number = -1;
  @Link deleteList: Array<BillItem> ;
  @Link uniqueTimes: Array<string> ;
  @Link selectedDate:Date;
  @Link totalIncomes:number;
  @Link totalExpenses:number ;

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
        delay: 500
      })).combine(TransitionEffect.asymmetric(TransitionEffect.move(TransitionEdge.END),
      TransitionEffect.move(TransitionEdge.START)))
  }


  @State newBill: BillItem ={
    id:-1,
    remark:'',
    title:'',
    time:'',
    amount:0,
    method:'',
    accountType: 0
  };


  @State isShow: boolean = true;
  @State egDivider: DividerTmp = new DividerTmp(1, 60, 10, '#ffe9f0f0')

  @State totalIncome: number = 0;
  @State totalExpense: number = 0;

  private billItemTable = new BillItemTable(() => {});

  dialogController: CustomDialogController = new CustomDialogController({
    builder: EditComponent({
      isInsert: $isInsert,
      newBill: $newBill,
      confirm: (isInsert: boolean, newAccount: BillItem) => this.accept(isInsert, newAccount)
    }),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  });

  accept(isInsert: boolean, newBill: BillItem): void {
    if (isInsert) {
      // Logger.info(`${CommonConstants.INDEX_TAG}`, `The account inserted is:  ${JSON.stringify(newBill)}`);
      // this.billItemTable.insertData(newBill, (id: number) => {
      //   newBill.id = id;
      //   this.listData.push(newBill);
      // });
    }
    else {
      this.billItemTable.updateData(newBill, () => {
      });
      let list = this.listData;
      this.listData = [];
      list[this.index] = newBill;
      this.listData = list;
      this.index = -1;
    }
  }


  selectListItem(item: BillItem) {
    this.isInsert = false;
    this.index = this.listData.indexOf(item);
    this.newBill = {
      id: item.id,
      accountType: item.accountType,
      title: item.title,
      amount: item.amount,
      remark: item.remark,
      time: item.time,
      method: item.method
      //todo
    };
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



  build() {
    Column() {
      // 顶部汇总
      Row() {
        Text(this.time)
          .fontSize(14)
          .fontColor('#8F8F8F')
          // .backgroundColor('#F8F8F8')

        Row(){
          Text(`支出 -￥${this.totalExpense}`+`  收入 +￥${this.totalIncome}`)
            .fontSize(13)
            .fontColor('#8F8F8F')
            .margin({right:5})
            .textAlign(TextAlign.End);

          if (this.isShow) {
            Image($r('app.media.chevron_down'))
              .onClick(() => {
                this.isShow = !this.isShow;
              })
              .width(20)
              .height(20)
          } else {
            Image($r('app.media.chevron_right'))
              .onClick(() => {
                this.isShow = !this.isShow;
              })
              .margin({left:5,right:5})
              .width(10)
              .height(20)

          }
        }
        .margin({right:5})

      }
      .padding({ bottom: 10,left: 10,right: 10,top: 10})
      .width('95%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      // 列表内容
      if (this.isShow) {

        List(){
          ForEach(this.listData, (item: BillItem, index: number) => {
            if (this.timeUtil.formatMonthDay(item.time)+' '+this.timeUtil.getWeekday(item.time)===this.time){
              ListItem(){
                Row() {
                  Row(){
                    // 图标
                    Image(ImageList[item.title])
                      .width(40)
                      .height(40)
                      .borderRadius(20)
                      .backgroundColor(item.accountType==0?'#E74C3C':'#27AE60')
                      .fillColor(Color.White)
                      .padding(7)
                      .margin({right:10 });

                    // 文本内容
                    Column() {
                      Text(TextList[item.title]).fontSize(16).fontWeight('medium');
                      Text(this.timeUtil.formatTime(item.time)).fontSize(12).fontColor('#8F8F8F');
                    }
                    .alignItems(HorizontalAlign.Start)
                    // .margin(10);
                  }

                  Row(){
                    // 金额与支付方式
                    Column() {
                      Text((item.accountType==0?'-':'+')+'¥'+Math.abs(item.amount).toString())
                        .fontColor(item.accountType==0?'#E74C3C':'#27AE60')
                        .fontSize(16)
                        .fontWeight('medium');
                      Row(){
                        Image(ImageList[item.method])
                          .width(12)
                        Text(TextList[item.method])
                          .fontSize(12)
                          .fontColor('#888');
                      }

                    }
                    .justifyContent(FlexAlign.SpaceBetween)

                    if (!this.isEdit) {
                      // Text(item.accountType === 0 ? '-' + item.amount.toString() : '+' + item.amount.toString())
                      //   .fontSize($r('app.float.font_size_M'))
                      //   .fontColor(item.accountType === 0 ? $r('app.color.pay_color') : $r('app.color.main_color'))
                      //   .align(Alignment.End)
                      //   .flexGrow(CommonConstants.FULL_SIZE)
                    } else {
                      Row() {
                        Toggle({ type: ToggleType.Checkbox })
                          .onChange((isOn) => {
                            if (isOn) {
                              this.deleteList.push(item);
                            } else {
                              let index = this.deleteList.indexOf(item);
                              this.deleteList.splice(index, 1);
                            }
                          })
                      }
                      .align(Alignment.End)
                      // .flexGrow(CommonConstants.FULL_SIZE)
                      .justifyContent(FlexAlign.End)
                    }
                  }

                }
                .padding({ bottom: 10,left: 10,right: 10,top: 10})
                // .backgroundColor(Color.Red)
                .backgroundColor('#FFFFFF')
                .justifyContent(FlexAlign.SpaceBetween)
                .width("100%")
                // .alignItems(VerticalAlign.Center)
              }
              .transition(this.transitionTime)


              .onDisAppear(()=>{
                this.onDataChange();
                if (!item.accountType) {
                  this.totalExpense-=item.amount;
                }else {
                  this.totalIncome-=item.amount;
                }
              })
              .onAppear(()=>{
                if (!item.accountType) {
                  this.totalExpense+=item.amount;
                }else {
                  this.totalIncome+=item.amount;
                }
              })
              .onClick(()=>{
                //todo 实现编辑功能
                this.selectListItem(item);
                this.dialogController.open();
              })
              .swipeAction({end:this.DeleteButton(index)})
              // .swipeAction({
              //   end: {
              //     onAction: () => {
              //       this.setDeleteAnimation()
              //       animateTo({ duration: 1000 }, () => {
              //         this.billItemTable.deleteData(this.listData[index], () => {
              //         });
              //         this.listData.splice(index,1);
              //       })
              //     },
              //     actionAreaDistance: 56,
              //     onEnterActionArea: () => {
              //     },
              //     onExitActionArea: () => {
              //     }
              //   }
              // })
            }

          })
        }
        // .transition(this.effect_delete)
        .transition(this.transitionTime)
        .onDisAppear(()=>{
          this.totalIncome=0;
          this.totalExpense=0;
        })
        .backgroundColor('#F1F3F5')
        .divider(this.egDivider)
        .width("90%")
        .borderRadius(15)
      }
    }
    .width('100%')
  }

  @Builder DeleteButton(index: number) {
    Button() {
      Image($r('app.media.trash'))
        .fillColor(Color.White)
        .width(20)
    }
    .width(40)
    .height(40)
    .type(ButtonType.Circle)
    .backgroundColor(Color.Red)
    .margin(5)
    .onClick(() => {
      this.setDeleteAnimation()
      animateTo({
        duration: 500, curve: Curve.Smooth, onFinish: () => {
          this.transitionTime = (TransitionEffect.IDENTITY)
        }
      },() => {
        this.billItemTable.deleteData(this.listData[index], () => {
        });
        this.listData.splice(index,1);
      })

    })
    .onDisAppear(()=>this.onDataChange())
  }

  // /**
  //  * 业务组件
  //  * @param info
  //  */
  // @Builder
  // function HorizontalSlidingMenuChildren(info: BillItem) {
  //   Row() {
  //     // 图标
  //     Image($r(info.icon))
  //       .width(40)
  //       .height(40)
  //       .margin(10);
  //
  //     // 文本内容
  //     Column() {
  //       Text(info.title).fontSize(16).fontWeight('medium');
  //       Text(info.time).fontSize(14).fontColor('#888');
  //     }.margin(10);
  //
  //     // 金额与支付方式
  //     Column() {
  //       Text(info.amount.toString()).fontSize(16).fontWeight('medium');
  //       Text(info.method).fontSize(14).fontColor('#888');
  //     }
  //     .justifyContent(FlexAlign.SpaceBetween)
  //   }.padding({ bottom: 10 })
  //   .width("100%")
  //   .justifyContent(FlexAlign.SpaceBetween)
  //   // .alignItems(VerticalAlign.Center)
  // }

}
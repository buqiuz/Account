/*
 * Copyright (C) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import LineChartModel from '../charts/LineChartModel'
import { CustomUiInfo } from '../data/customUiData';
import { EventType } from '../listener/EventControl';

@Component
export default struct LineChart {
  model: LineChartModel | null = null;
  antiAliasing: boolean = true;
  private setting: RenderingContextSettings | null = null;
  private context2D: CanvasRenderingContext2D | null = null;
  private highlightSetting: RenderingContextSettings = new RenderingContextSettings(true);
  private highlightContext2D: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.highlightSetting);
  @Prop customUiInfo: CustomUiInfo | null = null;
  // 默认长按显示自定义ui
  @Prop customUiTriggerEvent: EventType = EventType.LongPress;

  aboutToAppear(): void {
    this.setting = new RenderingContextSettings(this.antiAliasing);
    this.context2D = new CanvasRenderingContext2D(this.setting);
  }

  invalidate(){
    this.model?.invalidate();
  }

  @Builder
  emptyBuilder() {
  };

  @BuilderParam customUiBuilder: () => void = this.emptyBuilder;

  public calcCustomUiInfo(ev: GestureEvent | TouchEvent) {

    if (!this.customUiInfo) {
      return;
    }

    if (!this.model) return;
    const pos = this.model.calcPos(false, ev);
    if (!pos) return;
    const entryData = this.model.getEntryByTouchPoint(pos[0], pos[1]);
    if (entryData) {
      const vph = this.model.getViewPortHandler();
      const isInbounds = vph.isInBounds(pos[0], pos[1]);
      // 距离左侧距离
      const offsetLeft = pos[0] - vph.offsetLeft();
      // 距离右侧
      const offsetRight = vph.getChartWidth() - pos[0] - vph.offsetRight();
      this.customUiInfo.isInbounds = isInbounds;
      this.customUiInfo.x = pos[0];
      this.customUiInfo.y = pos[1];
      this.customUiInfo.offsetLeft = offsetLeft;
      this.customUiInfo.offsetRight = offsetRight;
      this.customUiInfo.data = entryData;

      this.customUiInfo.showUi = true;
    }
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        Canvas(this.context2D)
          .onReady(() => {
            if (this.model && this.context2D) {
              this.model.setContext2D(this.context2D);
              this.model.onDraw(this.context2D);
            }
          })
          .onAreaChange((oldArea: Area, newArea: Area) => {
            if (this.model && ((newArea.width !== oldArea.width) || (newArea.height !== oldArea.height))) {
              this.model.onChartSizeChanged(Number(newArea.width), Number(newArea.height), Number(oldArea.width), Number(oldArea.height));
            }
          })
          .onTouch((event) => {
              this.model?.onTouchEvent(event);
          })
          .hitTestBehavior(this.model?.getTouchEnabled()? this.model?.getHitTestMode(): HitTestMode.None)
          .priorityGesture(GestureGroup(GestureMode.Exclusive,
            SwipeGesture()
              .onAction((event: GestureEvent) => {
                if (event && this.model) {
                  if (this.model.isDragDecelerationEnabled()) {
                    this.model.computeScroll(event);
                  }
                }
              }),
            GestureGroup(GestureMode.Parallel,
              TapGesture({ count: 2 })
                .onAction((event?: GestureEvent) => {
                  if (event && this.model) {
                    this.model.onDoubleTap(false, event);
                    if (this.customUiTriggerEvent === EventType.DoubleTap &&
                    this.model.eventControl.eventIsEnable(EventType.DoubleTap) && this.model.getTouchEnabled()
                    ) {
                      this.calcCustomUiInfo(event)
                    }
                  }
                }),
              TapGesture({ count: 1 })
                .onAction((event?: GestureEvent) => {
                  if (event && this.model) {
                    this.model.onSingleTapUp(false, event);
                    if (this.customUiTriggerEvent === EventType.SingleTap &&
                    this.model.eventControl.eventIsEnable(EventType.SingleTap) && this.model.getTouchEnabled()
                    ) {
                      this.calcCustomUiInfo(event)
                    }
                  }
                }),
            ),
            LongPressGesture({ duration: this.model?.getLongPressDuration() })
              .onAction((event?: GestureEvent) => {
                if (this.model && event) {
                  this.model.onLongPress(false, 'Down', event);
                  if (this.customUiTriggerEvent === EventType.LongPress &&
                  this.model.eventControl.eventIsEnable(EventType.LongPress) && this.model.getTouchEnabled()
                  ) {
                    this.calcCustomUiInfo(event);
                  }
                }
              })
              .onActionEnd((event?: GestureEvent) => {
                if (this.model && event) {
                  this.model.onLongPress(false, 'Up', event);
                }
              })
              .onActionCancel((event?: GestureEvent) => {
                if (this.model && event) {
                  this.model.onLongPress(false, 'Cancel', event);
                }
              }),
            PinchGesture({ fingers: 2 })
              .onActionStart((event?: GestureEvent) => {
                if (this.model && event) {
                  this.model.onPinch(false, 'Start', event);
                }
              })
              .onActionUpdate((event?: GestureEvent) => {
                if (this.model && event) {
                  this.model.onPinch(false, 'Update', event);
                }
              })
              .onActionEnd((event?: GestureEvent) => {
                if (this.model && event) {
                  this.model.onPinch(false, 'End', event);
                }
              })
              .onActionCancel((event?: GestureEvent) => {
                if (this.model && event) {
                  this.model.onPinch(false, 'Cancel', event);
                }
              })
          ))
          .scale({
            x: this.model?.getHorizontalFlip() ? -1 : 1
          })
        if (this.customUiInfo && this.customUiInfo.showUi) {
          this.customUiBuilder()
        }
        Canvas(this.highlightContext2D)
          .onReady(() => {
            this.model?.setHighlightContext2D(this.highlightContext2D);
          }).hitTestBehavior(HitTestMode.None)
      }
    }
  }
}


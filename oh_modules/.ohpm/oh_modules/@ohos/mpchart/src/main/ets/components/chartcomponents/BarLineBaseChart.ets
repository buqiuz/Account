/*
 * Copyright (C) 2024 Huawei Device Co., Ltd.
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

import BubbleChartModel from '../charts/BubbleChartModel';
import CandleStickChartModel from '../charts/CandleStickChartModel';
import CombinedChartModel from '../charts/CombinedChartModel';
import HorizontalBarChartModel from '../charts/HorizontalBarChartModel';
import ScatterChartModel from '../charts/ScatterChartModel';
import { LogUtil } from '../utils/LogUtil';

@Component
export struct BarLineBaseChart {
  model: BubbleChartModel | CandleStickChartModel | CombinedChartModel | ScatterChartModel | HorizontalBarChartModel | null =
    null;
  antiAliasing: boolean = true;
  private setting: RenderingContextSettings | null = null;
  private context2D: CanvasRenderingContext2D | null = null;

  invalidate() {
    this.model?.invalidate();
  }

  aboutToAppear() {
    LogUtil.log('-----------aboutToAppear: enter')
    this.setting = new RenderingContextSettings(this.antiAliasing);
    this.context2D = new CanvasRenderingContext2D(this.setting);
  }

  build() {
    Canvas(this.context2D)
      .onReady(() => {
        if (this.model && this.context2D) {
          this.model.setContext2D(this.context2D);
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
            if (this.model?.isDragDecelerationEnabled()) {
              this.model.computeScroll(event);
            }
          }),
        GestureGroup(GestureMode.Parallel,
          TapGesture({ count: 2 })
            .onAction((event?: GestureEvent) => {
              if (event && this.model) {
                this.model.onDoubleTap(false, event);
              }
            }),
          TapGesture({ count: 1 })
            .onAction((event?: GestureEvent) => {
              if (event && this.model) {
                this.model.onSingleTapUp(false, event);
              }
            })
        ),
        LongPressGesture({ duration: this.model?.getLongPressDuration() })
          .onAction((event?: GestureEvent) => {
            if (this.model && event) {
              this.model.onLongPress(false, 'Down', event);
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
  }
}